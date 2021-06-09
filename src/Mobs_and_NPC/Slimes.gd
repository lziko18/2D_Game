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
	$Sprite/AnimationPlayer.play("Slide")
	$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
	$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=false
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
	$Sprite/AnimationPlayer.play("Bite")
	$Sprite/Position2D/Player_detect/CollisionShape2D2.disabled=true
	motion.x=0

func hurt(_delta):
	motion.x=0
	$Sprite/AnimationPlayer.play("hurt")


func idle(_delta):
	motion.x=0
	$Sprite/AnimationPlayer.play("idle")


func player_knock():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Slimes").global_position.x
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
		if name=="hurt":
			health-=1




func _on_Player_detect_body_entered(_body):
	state=Attack


func _on_Weak_point_area_entered(area):
	if area.get_parent().name=="Player":
		if area.get_parent().motion.y<0:
			return
		elif area.get_parent().motion.y>0:
			area.get_parent().motion.y=-600
			area.get_parent().get_node("AnimationPlayer").stop()
			area.get_parent().get_node("AnimationPlayer").play("Player Jumping")
			if health>0:
				state=Hurt
			else:
				state=Die
				$Weak_point.queue_free()


