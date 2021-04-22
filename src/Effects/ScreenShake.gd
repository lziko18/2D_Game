extends Node

var curr_prio=0

func camera_move(vector):
	get_parent().offset=Vector2(rand_range(-vector.x,vector.x),rand_range(-vector.y,vector.y))
	

func screen_shake(shake_len,shake_pow,prio):
	if prio >curr_prio:
		curr_prio=prio
		$ShakeTween.interpolate_method(self,"camera_move",Vector2(shake_pow,shake_pow),Vector2(0,0),shake_len,Tween.TRANS_SINE,Tween.EASE_OUT,0)
		$ShakeTween.start()



func _on_ShakeTween_tween_completed(_object,_key):
	curr_prio=0
