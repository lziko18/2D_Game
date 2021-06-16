extends "res://Scripts/Entity.gd"

const UP=Vector2(0, -1)
const speed = 200
const gravity = 30

var motion = Vector2()

func _init():
	add_state("right")
	add_state("left")
	add_state("up")
	add_state("down")
	add_state("explode")

func _ready():
	if save_data == null:
		set_state(states.right)
		$Sprite/AnimationPlayer.play("Crawl")
	scale.x=0.5
	scale.y=0.5

func _state_logic(_delta):
	motion=move_and_slide(motion,UP)

func _get_transition():
	match state:
		states.right:
			if $down.is_colliding() and not $right.is_colliding():
				return states.down
		states.down:
			if $left.is_colliding() and not $down.is_colliding():
				return states.left
		states.left:
			if $up.is_colliding() and not $left.is_colliding():
				return states.up
		states.up:
			if $right.is_colliding() and not $up.is_colliding():
				return states.right
	return null


func _enter_state(_new_state, _old_state):
	match _new_state:
		states.right:
			motion.y=0
			motion.x=speed
			$Sprite.rotation_degrees=0
			$Area2D2.rotation_degrees=0
		states.left:
			motion.y=0
			motion.x=-speed
			$Sprite.rotation_degrees=180
			$Area2D2.rotation_degrees=180
		states.up:
			motion.x=0
			motion.y=-speed
			$Sprite.rotation_degrees=-90
			$Area2D2.rotation_degrees=-90
		states.down:
			motion.x=0
			motion.y=speed
			$Sprite.rotation_degrees=90
			$Area2D2.rotation_degrees=90
		states.explode:
			$Sprite/AnimationPlayer.play("Explode")
			motion.x=0
			motion.y=0
			set_physics_process(false)

func _on_Area2D_body_entered(_body):
	set_state(states.explode)

func zise():
	$Sprite.scale.x=3.5
	$Sprite.scale.y=3.5
	if $Sprite.rotation_degrees==0:
		$Sprite.position.x=-40.454
		$Sprite.position.y=-128.547
	elif $Sprite.rotation_degrees==90:
		$Sprite.position.x=128.547
		$Sprite.position.y=-40.454
	elif $Sprite.rotation_degrees==-90:
		$Sprite.position.x=-128.547
		$Sprite.position.y=40.454
	elif $Sprite.rotation_degrees==180:
		$Sprite.position.x=40.454
		$Sprite.position.y=128.547

func del():
	self.queue_free()

func get_save_data():
	var data = {
		"state": get_state_by_id(state),
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"motion": {
			"x": motion.x,
			"y": motion.y
		},
		"animation": {
			"name": $Sprite/AnimationPlayer.current_animation,
			"position": $Sprite/AnimationPlayer.current_animation_position
		}
	}
	return data

func set_from_save_data(data):
	set_state(states[data.state])
	global_position.x = data.position.x
	global_position.y = data.position.y
	motion.x = data.motion.x
	motion.y = data.motion.y
	$Sprite/AnimationPlayer.play(data.animation.name)
	$Sprite/AnimationPlayer.seek(data.animation.position)

func get_entity_name():
	return "Crawler"

	
