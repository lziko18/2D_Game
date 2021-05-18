extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass






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
