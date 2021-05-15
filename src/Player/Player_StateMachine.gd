extends "res://Scripts/StateMachine.gd"

const UP=Vector2(0,-1)

enum Direction { RIGHT = 1, LEFT = -1 }
var running_speed : float = 350
var falling_speed_x : float = 400
var gravity : float = 60
var jump_acceleration : float = 1200
var double_jump_acceleration : float = 1000
var fall_threshold : float = 550

var facing_direction
var velocity = Vector2()
var has_double_jumped : bool = false
var attack_queued : bool = false
var attack_animation_finished : bool = true

func _ready():
	set_direction(Direction.RIGHT)
	
	add_state("idle")
	add_state("running")
	add_state("falling")
	add_state("jumping")
	add_state("double_jumping")
	add_state("attack_1")
	add_state("attack_2")
	add_state("attack_3")
	call_deferred("set_state", states.idle)
	
	add_input_action("player_right", KEY_RIGHT)
	add_input_action("player_left", KEY_LEFT)
	add_input_action("player_jump", KEY_UP)
	add_input_action("player_attack", KEY_Q)


func add_input_action(name, key):
	InputMap.add_action(name)
	var ev = InputEventKey.new()
	ev.scancode = key
	InputMap.action_add_event(name, ev)
	
func _input_logic(event):
	if event.is_action_pressed("player_right"):
		set_direction(Direction.RIGHT)
	elif event.is_action_pressed("player_left"):
		set_direction(Direction.LEFT)
	match state:
		states.attack_1:
			if event.is_action_pressed("player_attack"):
				attack_queued = true
	pass

func _state_logic(delta):
	velocity.y += gravity
	match state:
		states.running:
			velocity.x = running_speed * facing_direction
			pass
		states.idle:
			pass
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
			pass
	velocity = move_and_slide(velocity, UP)

func _get_transition():
	match state:
		states.idle:
			if Input.is_action_just_pressed("player_attack"):
				return states.attack_1
			if !is_on_floor():
				return states.falling
			elif Input.is_action_just_pressed("player_jump"):
				return states.jumping
			if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
				return states.running
		states.running:
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
			if is_on_floor():
				if Input.is_action_pressed("player_right") || Input.is_action_pressed("player_left"):
					return states.running
				else:
					return states.idle
			elif Input.is_action_just_pressed("player_jump") && velocity.y > -jump_acceleration && !has_double_jumped:
				return states.double_jumping
		states.jumping:
			if is_on_floor():
				return states.idle
			else:
				if Input.is_action_just_pressed("player_jump") && velocity.y > gravity - jump_acceleration && !has_double_jumped:
					return states.double_jumping
				elif velocity.y >= fall_threshold:
					return states.falling
		states.double_jumping:
			if is_on_floor():
				return states.idle
			elif velocity.y >= fall_threshold:
				return states.falling
		states.attack_1:
			if attack_animation_finished:
				if attack_queued:
					return states.attack_2
				else:
					return states.idle
		states.attack_2:
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
			attack_queued = false
			velocity.x = 0
			print("attack_1")
		states.attack_2:
			$AnimationPlayer.play("Attack2")
			attack_animation_finished = false
			attack_queued = false
			velocity.x = 0
			print("attack_2")

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
			attack_queued = false
		states.attack_2:
			attack_queued = false
			velocity.x = 0
	pass

func _on_AnimationPlayer_animation_started(animation_name):
	pass
	
func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == "Attackt1":
		attack_animation_finished = true
	elif animation_name == "Attack2":
		attack_animation_finished = true
	pass

func set_direction(dir):
	facing_direction = dir
	$Sprite.flip_h = (dir == Direction.LEFT)
