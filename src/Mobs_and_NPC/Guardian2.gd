extends "res://Scripts/Entity.gd"

export (int) var face = 1
var health : int = 2

func _init():
	add_state("idle")
	add_state("hit_da_boy")
	add_state("death")

func _ready():
	if save_data == null:
		set_state(states.idle)
		set_direction(face)

func _input_logic(_event):
	pass

func _state_logic(_delta):
	pass
	
func _get_transition():
	return null
	
func _enter_state(new_state, _old_state):
	match(new_state):
		states.idle:
			$Sprite/AnimationPlayer.play("Idle")
			$Sprite/Position2D/Player_detect/CollisionShape2D.disabled=false
		states.hit_da_boy:
			$Sprite/AnimationPlayer.play("Hit_da_boy")
			$Sprite/Position2D/Player_detect/CollisionShape2D.set_deferred("disabled",true)
		states.death:
			$Sprite/AnimationPlayer.play("Guardian_death")
			$Sprite/Hurtbox.queue_free()
			$Sprite/Position2D/Area2D.queue_free()
	
func _exit_state(_old_state, _new_state):
	match(_old_state):
		states.idle:
			pass
		states.hit_da_boy:
			$Sprite/Position2D/Area2D.scale.y=1
			$Sprite/Position2D/Area2D.rotation_degrees=0
		states.death:
			pass

func set_direction(direction):
	face = direction
	if face == 1:
		$Sprite.scale.x=1
		$Sprite.position.x=0
	elif face == -1:
		$Sprite.scale.x=-1
		$Sprite.position.x=46.375

func _on_AnimationPlayer_animation_finished(name):
	if name=="Hit_da_boy":
		set_state(states.idle)
	if name=="Guardian_death":
		queue_free()

func _on_Player_detect_body_entered(body):
	if body.can_be_detected==true:
		if state == states.idle:
			set_state(states.hit_da_boy)

func _on_Hurtbox_area_entered(_area):
	health-=1
	if health<=0:
		set_state(states.death)

func get_save_data():
	var data = {
		"state": get_state_by_id(state),
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"animation": {
			"name": $Sprite/AnimationPlayer.current_animation,
			"position": $Sprite/AnimationPlayer.current_animation_position
		},
		"health": health,
		"face": face
	}
	return data

func set_from_save_data(data):
	set_state(states[data.state])
	global_position.x = data.position.x
	global_position.y = data.position.y
	$Sprite/AnimationPlayer.play(data.animation.name)
	$Sprite/AnimationPlayer.seek(data.animation.position)
	health = data.health
	set_direction(data.face)

func get_entity_name():
	return "Guardian"
