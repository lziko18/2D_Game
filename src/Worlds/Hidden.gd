extends Node

onready var root=get_tree().get_root()





# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false
	yield(get_tree().create_timer(1.1), "timeout")
	$Player/Camera2D/CanvasLayer/Label/AnimationPlayer.play("Hide")
	









func _on_Hide1_area_body_entered(body):
	if body.name=="Player":
		$Hide1/AnimationPlayer.play("Unhide")


func _on_Hide2_area_body_entered(body):
	if body.name=="Player":
		$Hide2/AnimationPlayer.play("Unhide")

func _on_Hide1_area_body_exited(body):
	if body.name=="Player":
		$Hide1/AnimationPlayer.play("Hide")


func _on_Hide2_area_body_exited(body):
	if body.name=="Player":
		$Hide2/AnimationPlayer.play("Hide")
