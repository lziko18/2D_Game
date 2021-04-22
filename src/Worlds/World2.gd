extends Node
onready var root=get_tree().get_root()
func _ready():
	get_tree().paused=true
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false
	print("6")
