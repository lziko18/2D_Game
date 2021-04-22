extends KinematicBody2D
onready var player_push=$Position2D/Sprite2/Area2D


# var a = 2

var point=Vector2(800,800)
var x
var koti=Vector2()
func _ready():
	yield(get_tree().create_timer(0.6), "timeout")
	$Sprite/AnimationPlayer.play("laser")



func activate_laser_beam():	
	$Position2D/Sprite2/AnimationPlayer.play("laser")

func activate_laser_beam2():
	$Position2D/Sprite3/AnimationPlayer.play("laser")

func activate_laser_beam3():
	$Position2D/Sprite4/AnimationPlayer.play("laser")

func find_angle():
	x=get_angle_to(point)
	print(point.x)
	print(point.y)
	print(x)
	$Position2D.rotate(x)

func clearall():
		$Position2D.rotation_degrees=0

func fliperor():
	if $Sprite.position.x < koti.x:
		$Sprite.flip_h=true
	elif $Sprite.position.x > koti.x:
		$Sprite.flip_h=false
	
	
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="laser":
		fliperor()
		$Position2D/Sprite2.frame=0
		$Position2D/Sprite3.frame=0
		$Position2D/Sprite4.frame=0
		$Sprite/AnimationPlayer.play("laser")
		clearall()











func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name=="laser":
		find_angle()
