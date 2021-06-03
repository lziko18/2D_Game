extends KinematicBody2D

const UP = Vector2(0, -1);
var GRAVITY = 500;
var motion = Vector2()
var stoped=false
var anime_palyed=false
var speed=500
var speed2=500
var velocity = Vector2()
func check():
	if is_on_floor():
		stoped=true


func _physics_process(delta):
	motion.y = speed2*2
	motion=move_and_slide(motion,UP)
	check()
	if stoped==true:
		motion.x=0
		if anime_palyed==false:
			$AnimationPlayer.play("land")
	else:
		motion.x=speed*2
		$AnimationPlayer.play("Roll")
	motion=move_and_slide(motion,UP)
	yield(get_tree().create_timer(1.35), "timeout")
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="land":
		anime_palyed=true
