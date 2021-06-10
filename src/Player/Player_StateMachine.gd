extends "res://Scripts/StateMachine.gd"

var fireball = preload("res://Skills/Fireball.tscn")

var running_speed : float = 350
var crouch_speed : float = 200
var sliding_start_speed : float = running_speed
var sliding_acceleration : float = -2
var attack_3_speed : float = 220
var attack_air_speed : float = 800
var falling_speed_x : float = 400
var gravity : float = 60
var jump_acceleration : float = 1200
var double_jump_acceleration : float = 1000
var fall_threshold : float = 550
var wall_sliding_speed : float = 200
var wall_slide_collision_vector : Vector2 = Vector2(30, 0)
var wall_grab_collision_vector_1 : Vector2 = Vector2(30, 0)
var wall_grab_collision_vector_2 : Vector2 = Vector2(30, 0)

const collision_offset_normal = Vector2(0, 0)
const collision_offset_crouch = Vector2(0, 12)
const collision_normal = Vector2(26, 56)
const collision_crouch = Vector2(26, 30)
const UP=Vector2(0,-1)
enum Direction { RIGHT = 1, LEFT = -1 }

var facing_direction
var velocity = Vector2()
var has_double_jumped : bool = false
var attack_queued : int = 0
var attack_animation_finished : bool = true
var sliding_finished : bool = false
var health_current : int
var health_max : int

var save_data = null
var player_health_ui

func _init():
	add_state("idle")
	add_state("running")
	add_state("crouch_idle")
	add_state("crouch_moving")
	add_state("sliding")
	add_state("falling")
	add_state("jumping")
	add_state("double_jumping")
	add_state("attack_1")
	add_state("attack_2")
	add_state("attack_3")
	add_state("air3")
	add_state("ground_slam")
	add_state("hurt")
	add_state("death")
	add_state("wall_slide")
	add_state("wall_grab")
	add_state("casting")
	
	add_input_action("player_right", KEY_RIGHT)
	add_input_action("player_left", KEY_LEFT)
	add_input_action("player_jump", KEY_UP)
	add_input_action("player_attack", KEY_Q)
	add_input_action("player_crouch", KEY_C)
	add_input_action("player_cast", KEY_W)
	add_input_action("player_health_1", KEY_E)
	add_input_action("player_health_2", KEY_R)
	
func load_save(data):
	save_data = data

func _ready():
	player_health_ui = get_tree().get_root().get_node("World/Player/Game_UI/CanvasLayer/Player_Health")
	if save_data == null:
		set_direction(Direction.RIGHT)
		set_state(states.idle)
		$CollisionShape2D.shape.set_extents(collision_normal)
		health_max = 5
		update_max_health()
		health_current = 5
		update_health()
	else:
		set_from_save_data(save_data)

func add_input_action(name, key):
	InputMap.add_action(name)
	var ev = InputEventKey.new()
	ev.scancode = key
	InputMap.action_add_event(name, ev)
	
func _input_logic(event):
	if event.is_action_pressed("player_health_1"):
		add_health(1)
	elif event.is_action_pressed("player_health_2"):
		take_damage(1)
	if state != states.wall_grab and state != states.sliding and state != states.death:
		if event.is_action_pressed("player_right"):
			set_direction(Direction.RIGHT)
		elif event.is_action_pressed("player_left"):
			set_direction(Direction.LEFT)
	match state:
		states.attack_1:
			if event.is_action_pressed("player_attack"):
				attack_queued += 1
		states.attack_2:
			if event.is_action_pressed("player_attack"):
				attack_queued += 1
		

func _state_logic(delta):
	velocity.y += gravity
	match state:
		states.running:
			velocity.x = running_speed * facing_direction
		states.idle:
			velocity.x = 0
		states.falling:
			if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
				velocity.x = falling_speed_x * facing_direction
			else:
				velocity.x = 0
		states.jumping:
			if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
				velocity.x = falling_speed_x * facing_direction
			else:
				velocity.x = 0
		states.double_jumping:
			if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
				velocity.x = falling_speed_x * facing_direction
			else:
				velocity.x = 0
		states.attack_1:
			velocity.x = 0
			velocity.y = 0
		states.attack_2:
			velocity.x = 0
			velocity.y = 0
		states.attack_3:
			velocity.x = attack_3_speed * facing_direction
			velocity.y = 0
		states.air3:
			velocity.y = attack_air_speed
		states.crouch_idle:
			velocity.x = 0
		states.crouch_moving:
			velocity.x = crouch_speed * facing_direction
		states.sliding:
			if facing_direction == Direction.RIGHT:
				if velocity.x - sliding_acceleration > 0:
					velocity.x += sliding_acceleration
				else:
					velocity.x = 0
			elif facing_direction == Direction.LEFT:
				if velocity.x - sliding_acceleration < 0:
					velocity.x -= sliding_acceleration
				else:
					velocity.x = 0
		states.wall_slide:
			velocity.x = 0
			velocity.y = wall_sliding_speed
		states.wall_grab:
			velocity.x = 0
			velocity.y = 0
		states.casting:
			velocity.x = 0
			velocity.y = 0
	velocity = move_and_slide(velocity, UP)

func _get_transition():
	if health_current <= 0 and state != states.death:
		return states.death
	match state:
		states.idle:
			if Input.is_action_just_pressed("player_cast"):
				return states.casting
			if Input.is_action_just_pressed("player_crouch"):
				return states.crouch_idle
			if Input.is_action_just_pressed("player_attack"):
				return states.attack_1
			if !is_on_floor():
				return states.falling
			elif Input.is_action_just_pressed("player_jump"):
				return states.jumping
			if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
				return states.running
		states.running:
			if Input.is_action_just_pressed("player_cast"):
				return states.casting
			if Input.is_action_just_pressed("player_crouch"):
				return states.sliding
			if Input.is_action_just_pressed("player_attack"):
				return states.attack_1
			if !is_on_floor():
				return states.falling
			elif Input.is_action_just_pressed("player_jump"):
				return states.jumping
			match facing_direction:
				Direction.RIGHT:
					if Input.is_action_just_released("player_right"):
						return states.idle
					elif Input.is_action_just_pressed("player_left"):
						return states.running
				Direction.LEFT:
					if Input.is_action_just_released("player_left"):
						return states.idle
					elif Input.is_action_just_pressed("player_right"):
						return states.running
		states.falling:
			if Input.is_action_just_pressed("player_cast"):
				return states.casting
			if Input.is_action_just_pressed("player_attack"):
				return states.attack_1
			if is_on_floor():
				if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
					return states.running
				else:
					return states.idle
			elif Input.is_action_just_pressed("player_jump") && velocity.y > -jump_acceleration && !has_double_jumped:
				return states.double_jumping
			elif $WallGrabCollision_2.is_colliding() and (not $WallGrabCollision_1.is_colliding()):
				return states.wall_grab
			elif $WallSlideCollision_1.is_colliding() and $WallSlideCollision_2.is_colliding():
				return states.wall_slide
		states.jumping:
			if Input.is_action_just_pressed("player_cast"):
				return states.casting
			elif Input.is_action_just_pressed("player_attack"):
				return states.attack_1
			else:
				if Input.is_action_just_pressed("player_jump") && velocity.y > gravity - jump_acceleration && !has_double_jumped:
					return states.double_jumping
				elif velocity.y >= fall_threshold:
					return states.falling
		states.double_jumping:
			if Input.is_action_just_pressed("player_cast"):
				return states.casting
			if is_on_floor():
				return states.idle
			elif velocity.y >= fall_threshold:
				return states.falling
		states.attack_1:
			if attack_animation_finished:
				if attack_queued > 0:
					return states.attack_2
				else:
					return states.idle
		states.attack_2:
			if attack_animation_finished:
				if attack_queued > 0:
					if $AirAttackCollisionFloor.is_colliding():
						return states.attack_3
					else:
						return states.air3
				else:
					return states.idle
		states.attack_3:
			if attack_animation_finished:
				return states.idle
		states.air3:
			if is_on_floor():
				return states.ground_slam
		states.crouch_idle:
			if Input.is_action_just_pressed("player_left") || Input.is_action_just_pressed("player_right"):
				return states.crouch_moving
			if !Input.is_action_pressed("player_crouch"):
				if $CrouchCollisionCeil.is_colliding():
					return null
				else:
					return states.idle
		states.crouch_moving:
			match facing_direction:
				Direction.RIGHT:
					if Input.is_action_just_released("player_right"):
						return states.crouch_idle
					elif Input.is_action_just_pressed("player_left"):
						return states.crouch_moving
				Direction.LEFT:
					if Input.is_action_just_released("player_left"):
						return states.crouch_idle
					elif Input.is_action_just_pressed("player_right"):
						return states.crouch_moving
			if !Input.is_action_pressed("player_crouch"):
				if $CrouchCollisionCeil.is_colliding():
					return null
				else:
					return states.idle
		states.sliding:
			if !Input.is_action_pressed("player_crouch"):
				if $CrouchCollisionCeil.is_colliding():
					return null
				else:
					return states.idle
			elif sliding_finished or velocity.x == 0:
				if $CrouchCollisionCeil.is_colliding():
					return states.crouch_idle
				else:
					return states.idle
		states.wall_slide:
			if is_on_floor():
				return states.idle
			elif not $WallSlideCollision_1.is_colliding():
				return states.falling
			elif Input.is_action_just_pressed("player_jump"):
				return states.jumping
			elif $WallGrabCollision_2.is_colliding() and (not $WallGrabCollision_1.is_colliding()):
				return states.wall_grab
		states.wall_grab:
			if Input.is_action_just_pressed("player_jump"):
				return states.jumping
		states.hurt:
			if attack_animation_finished:
				return states.idle
		states.death:
			return null
		states.casting:
			if attack_animation_finished:
				return states.idle
		states.ground_slam:
			if attack_animation_finished:
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			$AnimationPlayer.play("Player Idle")
			velocity.x = 0
			print("idle")
		states.running:
			$AnimationPlayer.play("Player Running")
			print("running")
		states.falling:
			$AnimationPlayer.play("Player Falling")
			velocity.x = 0
			velocity.y = 0
			print("falling")
		states.jumping:
			$AnimationPlayer.play("Player Jumping")
			velocity.y = -jump_acceleration
			print("jumping")
		states.double_jumping:
			$AnimationPlayer.play("Double Jump")
			velocity.y = -double_jump_acceleration
			has_double_jumped = true
			print("double_jumping")
		states.attack_1:
			$AnimationPlayer.play("Attackt1")
			attack_animation_finished = false
			attack_queued = 0
			print("attack_1")
		states.attack_2:
			$AnimationPlayer.play("Attack2")
			attack_animation_finished = false
			attack_queued -= 1
			print("attack_2")
		states.attack_3:
			$AnimationPlayer.play("Attack3")
			attack_animation_finished = false
			attack_queued -= 1
			print("attack_3")
		states.air3:
			$AnimationPlayer.play("air3")
			attack_animation_finished = false
			attack_queued -= 1
			print("air3")
		states.ground_slam:
			$AnimationPlayer.play("Ground_slam")
			attack_animation_finished = false
			print("ground_slam")
		states.crouch_idle:
			$AnimationPlayer.play("CrouchIdle")
			$CollisionShape2D.shape.set_extents(collision_crouch)
			$CollisionShape2D.set_position(Vector2(0, collision_normal.y - collision_crouch.y))
			print("crouch_idle")
		states.crouch_moving:
			$AnimationPlayer.play("CrouchIdle")
			$CollisionShape2D.shape.set_extents(collision_crouch)
			$CollisionShape2D.set_position(Vector2(0, collision_normal.y - collision_crouch.y))
			print("crouch_moving")
		states.sliding:
			velocity.x = sliding_start_speed * facing_direction
			sliding_finished = false
			$AnimationPlayer.play("Slide")
			$CollisionShape2D.shape.set_extents(collision_crouch)
			$CollisionShape2D.set_position(Vector2(0, collision_normal.y - collision_crouch.y))
			print("sliding")
		states.wall_slide:
			velocity.x = 0
			velocity.y = wall_sliding_speed
			$AnimationPlayer.play("Wall_Slide")
			print("wall_slide")
		states.wall_grab:
			velocity.x = 0
			velocity.y = 0
			$AnimationPlayer.play("Grab")
			print("wall_grab")
		states.casting:
			velocity.x = 0
			velocity.y = 0
			attack_animation_finished = false
			$AnimationPlayer.play("Player Casting")
			print("casting")
		states.hurt:
			health_current = health_current - 1
			player_health_ui.set_max_hearts(health_max)
			player_health_ui.set_hearts(health_current)
			velocity.x = 0
			velocity.y = 0
			attack_animation_finished = false
			$AnimationPlayer.play("Hurt")
			print("hurt")
		states.death:
			velocity.x = 0
			velocity.y = 0
			$AnimationPlayer.play("Player Die")
			print("death")

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.running:
			pass
		states.falling:
			if is_on_floor():
				has_double_jumped = false
			pass
		states.jumping:
			if is_on_floor():
				has_double_jumped = false
			pass
		states.double_jumping:
			if is_on_floor():
				has_double_jumped = false
		states.attack_1:
			pass
		states.attack_2:
			velocity.x = 0
		states.attack_3:
			pass
		states.crouch_moving:
			if new_state != states.crouch_idle:
				$CollisionShape2D.shape.set_extents(collision_normal)
				$CollisionShape2D.set_position(Vector2(0, 0))
		states.crouch_idle:
			if new_state != states.crouch_moving:
				$CollisionShape2D.shape.set_extents(collision_normal)
				$CollisionShape2D.set_position(Vector2(0, 0))
		states.sliding:
			if new_state != states.crouch_moving and new_state != states.crouch_idle:
				$CollisionShape2D.shape.set_extents(collision_normal)
				$CollisionShape2D.set_position(Vector2(0, 0))
		states.casting:
			var fireball_cast = fireball.instance()
			fireball_cast.knockback_vector=300 * facing_direction
			fireball_cast.get_fireball_direction(facing_direction)
			fireball_cast.position=global_position
			get_tree().get_root().get_node("World").add_child(fireball_cast)
	pass

func _on_AnimationPlayer_animation_started(animation_name):
	pass
	
func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == "Attackt1":
		attack_animation_finished = true
	elif animation_name == "Attack2":
		attack_animation_finished = true
	elif animation_name == "Attack3":
		attack_animation_finished = true
	elif animation_name == "Slide":
		sliding_finished = true
	elif animation_name == "air3":
		attack_animation_finished = true
	elif animation_name == "Ground_slam":
		attack_animation_finished = true
	elif animation_name == "Player Casting":
		attack_animation_finished = true
	elif animation_name == "Hurt":
		attack_animation_finished = true
	pass

func set_direction(dir):
	facing_direction = dir
	$Sprite.flip_h = (dir == Direction.LEFT)
	$WallSlideCollision_1.set_cast_to(Vector2(wall_slide_collision_vector.x * facing_direction, wall_slide_collision_vector.y))
	$WallSlideCollision_2.set_cast_to(Vector2(wall_slide_collision_vector.x * facing_direction, wall_slide_collision_vector.y))
	$WallGrabCollision_1.set_cast_to(Vector2(wall_grab_collision_vector_1.x * facing_direction, wall_grab_collision_vector_1.y))
	$WallGrabCollision_2.set_cast_to(Vector2(wall_grab_collision_vector_2.x * facing_direction, wall_grab_collision_vector_2.y))

func reset_health():
	health_current = health_max
	update_health()

func take_damage(amount):
	health_current = health_current - amount
	update_health()
	
func heal(amount):
	health_current = health_current + amount
	if health_current > health_max:
		health_current = health_max
	update_health()

func add_health(amount):
	health_max = health_max + amount
	health_current = health_current + amount
	update_max_health()
	update_health()

func update_health():
	player_health_ui.set_hearts(health_current)
	
func update_max_health():
	player_health_ui.set_max_hearts(health_max)

func get_save_data():
	
	var data = {
		"state": get_state_by_id(state),
		"position": {
			"x": position.x,
			"y": position.y
		},
		"velocity": {
			"x": velocity.x,
			"y": velocity.y
		},
		"facing_direction": facing_direction,
		"has_double_jumped": has_double_jumped,
		"attack_queued": attack_queued,
		"attack_animation_finished": attack_animation_finished,
		"hitbox_extents": {
			"x": $CollisionShape2D.shape.get_extents().x,
			"y": $CollisionShape2D.shape.get_extents().y
		},
		"animation": {
			"name": $AnimationPlayer.current_animation,
			"position": $AnimationPlayer.current_animation_position
		},
		"health": {
			"current": health_current,
			"max": health_max
		}
	}
	return data

func set_from_save_data(data):
	set_state(states[data.state])
	state = states[data.state]
	position.x = data.position.x
	position.y = data.position.y
	velocity.x = data.velocity.x
	velocity.y = data.velocity.y
	set_direction(data.facing_direction)
	has_double_jumped = data.has_double_jumped
	attack_queued = data.attack_queued
	attack_animation_finished = data.attack_animation_finished
	var hitbox_extents = data.hitbox_extents
	$CollisionShape2D.shape.set_extents(Vector2(hitbox_extents.x, hitbox_extents.y))
	$AnimationPlayer.play(data.animation.name)
	$AnimationPlayer.seek(data.animation.position)
	health_max = data.health["max"]
	update_max_health()
	health_current = data.health.current
	update_health()
