extends "res://Scripts/StateMachine.gd"

const UP=Vector2(0,-1)
const speed=40
const gravity=30

export (int) var direction=1
var motion= Vector2()
var health=2

onready var player_push=$Sprite/Position2D/Area2D
onready var player_push1=$Sprite/kot
var player = null

var save_data = null

func _init():
	add_state("Wander")
	add_state("Idle")
	add_state("Attack")
	add_state("Hurt")
	add_state("Die")

func _ready():
	set_direction(direction)

func _input_logic(event):
	pass

func _state_logic(delta):
	player_knock()
	match state:
		states.Wander:
			if $Sprite/Position2D/RayCast2D.is_colliding() or !$Sprite/Position2D/RayCast2D2.is_colliding():
				set_direction(-direction)
				print("colliding")
			motion.x = speed * direction
			motion.y += gravity
		states.Idle:
			motion.x = 0
		states.Attack:
			motion.x = 0
		states.Hurt:
			motion.x = 0
		states.Die:
			motion.x = 0
	motion = move_and_slide(motion,UP)
	
func player_knock():
	if player == null:
		player = get_tree().get_root().get_node("World/Player")
	var dir = player.global_position.x
	var our = global_position.x
	if our<dir:
		player_push1.knockback_vector=100
		player_push.knockback_vector=150
	else:
		player_push1.knockback_vector=-100
		player_push.knockback_vector=-150
	if $Sprite.flip_h==false:
		player_push.knockback_vector=-150
		player_push
	else:
		player_push.knockback_vector=150
	
func _get_transition():
	pass

func _enter_state(new_state, old_state):
	match state:
		states.Wander:
			$Sprite/AnimationPlayer.play("Slide")
		states.Attack:
			$Sprite/AnimationPlayer.play("Bite")
			$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
		states.Hurt:
			$Sprite/AnimationPlayer.play("hurt")
		states.Idle:
			$Sprite/AnimationPlayer.play("idle")
		states.Die:
			set_physics_process(false)
			$Sprite/AnimationPlayer.play("Death")
			$Sprite/Position2D.queue_free()
			$Sprite/kot.queue_free()
			$CollisionShape2D.queue_free()
			get_tree().get_root().get_node("World").entities[get_index()] = false

func _exit_state(old_state, new_state):
	pass

func set_direction(dir):
	if dir == 1:
		$Sprite.flip_h=true
		if sign($Sprite/Position2D.position.x)==-1:
			$Sprite/Position2D.position.x*=-1
			$Sprite/Position2D.scale.x=-1
	elif dir == -1:
		$Sprite.flip_h=false
		if sign($Sprite/Position2D.position.x)==1:
			$Sprite/Position2D.position.x*=-1
			$Sprite/Position2D.scale.x=1
	direction = dir
	$Sprite/AnimationPlayer.play("Slide")

func _on_AnimationPlayer_animation_finished(name):
	if name=="hurt":
		set_state(states.Idle)
	if name=="idle":
		set_state(states.Wander)
	if name=="Bite":
		set_state(states.Wander)
	if name=="Death":
		queue_free()

func _on_Player_detect_body_entered(_body):
	set_state(states.Attack)

func _on_Weak_point_area_entered(area):
	if area.get_parent().name=="Player":
		health-=1
		if player.motion.y>0:
			player.motion.x=0
			player.motion.y=-600
			player.first_jump=true
			player.jumps_left=1
			player.double_jump=false
			player.get_node("AnimationPlayer").stop()
			player.get_node("AnimationPlayer").play("Player Jumping")
			if health>0:
				set_state(states.Hurt)
			else:
				set_state(states.Die)
				$Weak_point.queue_free()
		else:
			print("bug")

func load_save(data):
	save_data = data

func get_save_data():
	var data = {
		"direction": direction,
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"motion": {
			"x": motion.x,
			"y": motion.y
		},
		"state": get_state_by_id(state),
		"animation": {
			"name": $Sprite/AnimationPlayer.current_animation,
			"position": $Sprite/AnimationPlayer.current_animation_position
		},
		"health": health
	}
	return data

func set_from_save_data(data):
	set_direction(data.direction)
	global_position.x = data.position.x
	global_position.y = data.position.y
	motion.x = data.motion.x
	motion.y = data.motion.y
	set_state(states[data.state])
	$Sprite/AnimationPlayer.play(data.animation.name)
	$Sprite/AnimationPlayer.seek(data.animation.position)
	health = data.health
