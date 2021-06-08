extends Node2D

func _ready():
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	yield(get_tree().create_timer(1.1), "timeout")
