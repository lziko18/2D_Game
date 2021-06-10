extends KinematicBody2D
export (int) var direction=1

export (int) var speed=40
const UP=Vector2(0,-1)
var motion= Vector2()
var gravity=30
var state
var health=2
onready var player_push=$Sprite/Position2D/Area2D
onready var player_push1=$Sprite/kot
enum{
	Wander,
	Idle
	Attack,
	Hurt,
	Die,
}

func _ready():
	state=Wander

func wander(_delta):
	motion.y+=gravity
	motion= move_and_slide(motion,UP)
	if $Sprite/AnimationPlayer.current_animation != "Slide":
		$Sprite/AnimationPlayer.play("Slide")
	#$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
	#$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=false
	if direction==1:
		$Sprite.flip_h=true
		motion.x=speed
		if $Sprite/Position2D/RayCast2D.is_colliding() or  !$Sprite/Position2D/RayCast2D2.is_colliding():
			direction=-1
			if sign($Sprite/Position2D.position.x)==1:
					$Sprite/Position2D.position.x*=-1
					$Sprite/Position2D.scale.x=1
	elif direction==-1:
		$Sprite.flip_h=false
		motion.x=-speed
		if $Sprite/Position2D/RayCast2D.is_colliding() or  !$Sprite/Position2D/RayCast2D2.is_colliding():
			direction=1
			if sign($Sprite/Position2D.position.x)==-1:
					$Sprite/Position2D.position.x*=-1
					$Sprite/Position2D.scale.x=-1

func attack(_delta):
	if $Sprite/AnimationPlayer.current_animation != "Bite":
		$Sprite/AnimationPlayer.play("Bite")
		$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
		motion.x=0

func hurt(_delta):
	if $Sprite/AnimationPlayer.current_animation != "hurt":
		$Sprite/AnimationPlayer.play("hurt")
		motion.x=0


func idle(_delta):
	if $Sprite/AnimationPlayer.current_animation != "idle":
		$Sprite/AnimationPlayer.play("idle")
		motion.x=0

func player_knock():
	var dir=get_tree().get_root().get_node("World/Player").global_position.x
	var our=global_position.x
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

func death():
	set_physics_process(false)
	$Sprite/AnimationPlayer.play("Death")
	$Sprite/Position2D.queue_free()
	$Sprite/kot.queue_free()
	$CollisionShape2D.queue_free()

func _physics_process(delta):
	player_knock()
	match state:
		Attack:
			attack(delta)
		Wander:
			wander(delta)
			
		Hurt:
			hurt(delta)
		Idle:
			idle(delta)
		Die:
			death()

func _on_AnimationPlayer_animation_finished(name):
	if name=="hurt":
		state=Idle
	if name=="idle":
		state=Wander
	if name=="Bite":
		$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
		$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=false
		state=Wander
	if name=="Death":
		queue_free()


func _on_AnimationPlayer_animation_started(name):
	pass


func _on_Player_detect_body_entered(_body):
	state=Attack


func _on_Weak_point_area_entered(area):
	if area.get_parent().name=="Player":
		health-=1
		if area.get_parent().motion.y<0:
			pass
		elif area.get_parent().motion.y>0:
			area.get_parent().motion.y=-600
			area.get_parent().first_jump=true
			area.get_parent().jumps_left=1
			area.get_parent().double_jump=false
			area.get_parent().get_node("AnimationPlayer").stop()
			area.get_parent().get_node("AnimationPlayer").play("Player Jumping")
			if health>0:
				state=Hurt
			else:
				state=Die
				$Weak_point.queue_free()

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
		"state": state,
		"animation": {
			"name": $Sprite/AnimationPlayer.current_animation,
			"position": $Sprite/AnimationPlayer.current_animation_position
		},
		"health": health
	}
	return data
	
func set_from_save_data(data):
	direction = data.direction
	global_position.x = data.position.x
	global_position.y = data.position.y
	motion.x = data.motion.x
	motion.y = data.motion.y
	state = data.state
	$Sprite/AnimationPlayer.play(data.animation.name)
	$Sprite/AnimationPlayer.seek(data.animation.position)
	health = data.health
	
