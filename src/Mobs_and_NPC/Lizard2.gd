extends "res://Scripts/Entity.gd"

const gravity = 30
const speed = 100
const UP = Vector2(0,-1)

export var direction = 1
var motion = Vector2()
var health = 3
var player_in_range = false

var rng = RandomNumberGenerator.new()


func _init():
	add_state("Wander")
	add_state("Attack")
	add_state("Hurt")
	add_state("Die")

func _ready():
	if save_data == null:
		set_state(states.Wander)
		set_direction(direction)

func _state_logic(_delta):
	match state:
		states.Wander:
			motion.y+=gravity
			if $RayCast2D.is_colliding() or  !$RayCast2D2.is_colliding():
				set_direction(-direction)
		states.Attack:
			pass
		states.Hurt:
			motion.y+=gravity
		states.Die:
			pass
	motion= move_and_slide(motion,UP)
	pass
	
func _get_transition():
	return null
	
func _enter_state(_new_state, _old_state):
	match _new_state:
		states.Wander:
			$Enemyanim.play("en walk")
			#$backhit/CollisionShape2D.disabled=true
			$Area2D/CollisionShape2D.disabled=true
			motion.x = speed * direction
			set_direction(direction)
		states.Attack:
			$Enemyanim.play("En att")
			#$backhit/CollisionShape2D.disabled=true
		states.Hurt:
			$Enemyanim.play("en hurt")
			$Area2D/CollisionShape2D.disabled=true
			$backhit/CollisionShape2D.disabled=false
		states.Die:
			$Enemyanim.play("en die")
			motion.x=0
			$CollisionShape2D.disabled=true
			$Hurtbox/CollisionShape2D.disabled=true
			$Area2D/CollisionShape2D.disabled=true
			$Player_detect/CollisionShape2D.disabled=true
			$backhit/CollisionShape2D.disabled=true
	
func _exit_state(_old_state, _new_state):
	match _old_state:
		states.Wander:
			motion.x = 0
		states.Attack:
			$Area2D/CollisionShape2D2.disabled = true
			pass
		states.Hurt:
			$backhit/CollisionShape2D.disabled=false
		states.Die:
			pass
	
func set_direction(dir):
	direction = dir
	if state == states.Wander:
		$Enemysprite.flip_h = (direction == 1)
		$backhit.position.x = -50 * direction
		$RayCast2D.scale.y = -1 * direction
		$RayCast2D2.position.x = 20 * direction
		$Area2D.position.x = 50 * direction
		$Player_detect.position.x = 35 * direction
		motion.x = speed * direction

func _on_Hurtbox_area_entered(area):
	health=health-1
	if health>0:
		set_state(states.Hurt)
		if area.name=="Att_hitbox":
			motion.x=area.knockback_vector/2 
		elif area.name=="Ground_slam_hitbox":
			motion.y=area.knockback_vector/2
	else:
		set_state(states.Die)


func _on_Player_detect_body_entered(body):
	if body.name=="Player":
		motion.x=0
		if state != states.Die:
			set_state(states.Attack)
			player_in_range = true

func _on_Enemyanim_animation_finished(anim_name):
	if anim_name=="En att":
		set_state(states.Wander)
		if player_in_range:
			set_state(states.Attack)
			
	if anim_name=="en hurt" and is_on_floor():
		set_state(states.Wander)
	if anim_name=="en die":
		queue_free()

func _on_Enemyanim_animation_started(anim_name):
	if anim_name != "En att":
		$Area2D/CollisionShape2D2.disabled = true
	if anim_name=="en die":
		$Area2D2/CollisionShape2D2.queue_free()


func _on_backhit_body_entered(body):
	if body.name == "Player":
		set_direction(-direction)
		print("Player_detected")


func _on_Player_detect_body_exited(body):
	if body.name=="Player":
		player_in_range = false

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
			"name": $Enemyanim.current_animation,
			"position": $Enemyanim.current_animation_position
		},
		"health": health,
		"direction": direction,
		"player_in_range": player_in_range
	}
	return data

func set_from_save_data(data):
	set_state(states[data.state])
	global_position.x = data.position.x
	global_position.y = data.position.y
	motion.x = data.motion.x
	motion.y = data.motion.y
	$Enemyanim.play(data.animation.name)
	$Enemyanim.seek(data.animation.position)
	health = data.health
	player_in_range = data.player_in_range
	set_direction(data.direction)

func get_entity_name():
	return "Lizard"
