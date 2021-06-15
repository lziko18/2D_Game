extends "res://Scripts/Entity.gd"

const speed : int = 200

var velocity : Vector2 = Vector2(0, 0)
var path : Array = []
var levelNavigation : Navigation2D = null
var player = null
var health = 2
var direction = 1

func _init():
	add_state("wander")
	add_state("attack")
	add_state("hurt")
	add_state("die")
	add_state("hunt")
	add_state("land")

func _ready():
	if save_data == null:
		set_state(0)
		set_direction(direction)
	yield(get_tree(), "idle_frame")
	$Line2D.global_position = Vector2(0, 0)
	$LineOfSight.enabled = true
	levelNavigation = get_tree().get_root().get_node("World/LevelNavigation")
	player = get_tree().get_root().get_node("World/Player")

func _input_logic(_event):
	pass

func _state_logic(_delta):
	if player:
		$LineOfSight.look_at(player.global_position)
		velocity = move_and_slide(velocity)
	else:
		player = get_tree().get_root().get_node("World/Player")
	match state:
		states.attack:
			pass
		states.wander:
			$AnimationPlayer.play("idle")
			if check_player_in_detection():
				set_state(states.hunt)
		states.hurt:
			pass
		states.die:
			velocity.y+=20
			if $RayCast2D.is_colliding():
				set_state(states.land)
		states.land:
			pass
		states.hunt:
			if (direction == -1 and player.global_position.x>global_position.x) or (direction == 1 and player.global_position.x<global_position.x):
				set_direction(-direction)
			if levelNavigation != null and player != null:
				path = levelNavigation.get_simple_path(global_position, player.global_position+Vector2(0,-30),false)
				$Line2D.points = path
			if path.size() > 0:
				velocity = global_position.direction_to(path[1]) * speed
				# If reached the destination, remove this point from path array
				if global_position == path[0]:
					path.pop_front()
			var x = player.global_position.x - global_position.x
			var y = player.global_position.y - global_position.y
			var distance = abs(x * x + y * y)
			if distance >= 600 * 600:
				set_state(states.wander)
			elif distance <= 30 * 30:
				set_state(states.attack)

func _get_transition():
	return null

func _enter_state(_new_state, _old_state):
	match state:
		states.attack:
			velocity.x=0
			velocity.y=0
			$AnimationPlayer.play("attack")
		states.wander:
			velocity.x=0
			velocity.y=0
			$AnimationPlayer.play("idle")
		states.hurt:
			$AnimationPlayer.play("hurt")
			health=health-1
			if health<=0:
				set_state(states.die)
		states.die:
			$AnimationPlayer.play("die")
			$Hurtbox/CollisionShape2D2.disabled=true
		states.land:
			$AnimationPlayer.play("land")
		states.hunt:
			$AnimationPlayer.play("move")
	print(get_state_by_id(_new_state))

func _exit_state(_old_state, _new_state):
	pass

func set_direction(dir):
	direction = dir
	if dir == 1:
		$Sprite.flip_h=true
		$Area2D.position.x=13
		$Sprite.position.x=13
	elif dir == -1:
		$Sprite.flip_h=false
		$Area2D.position.x=-13
		$Sprite.position.x=-13

func check_player_in_detection() -> bool:
	var collider = $LineOfSight.get_collider()
	if collider and collider.is_in_group("Player"):
		return true
	return false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="attack":
		set_state(states.wander)
	if anim_name=="hurt":
		set_state(states.wander)
	if anim_name=="land":
		queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name=="attack":
		yield(get_tree().create_timer(0.25), "timeout")
		if $Sprite.flip_h==true:
			velocity.x=400
		elif $Sprite.flip_h==false:
			velocity.x=-400
		yield(get_tree().create_timer(0.05), "timeout")
		velocity.x=0
		velocity.y=0


func _on_Hurtbox_area_entered(area):
	set_state(states.hurt)
	if area.name=="Att_hitbox":
		velocity.x=area.knockback_vector*0.5
	else:
		velocity.x=0

func get_save_data():
	var data = {
		"state": get_state_by_id(state),
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"animation": {
			"name": $AnimationPlayer.current_animation,
			"position": $AnimationPlayer.current_animation_position
		},
		"health": health,
		"direction": direction
	}
	return data

func set_from_save_data(data):
	set_state(states[data.state])
	global_position.x = data.position.x
	global_position.y = data.position.y
	$AnimationPlayer.play(data.animation.name)
	$AnimationPlayer.seek(data.animation.position)
	health = data.health
	set_direction(data.direction)

func get_entity_name():
	return "Pathfinder"
