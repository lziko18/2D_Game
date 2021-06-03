extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/Camera2D.limit_top=-317
	$Player/Camera2D.limit_right=25980
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		$Hidden1/AnimationPlayer.play("Unhide")


func _on_Area2D_body_exited(body):
	if body.name=="Player":
		$Hidden1/AnimationPlayer.play("Hide")


func _on_Area2D2_body_entered(body):
	if body.name=="Player":
		$Hidden2/AnimationPlayer.play("Unhide")


func _on_Area2D2_body_exited(body):
	if body.name=="Player":
		$Hidden2/AnimationPlayer.play("Hide")


func _on_Area2D3_body_entered(body):
	if body.name=="Player":
		$Player/Camera2D.limit_bottom=864
		$Player/Camera2D.limit_top=351
		$Player/Camera2D.limit_right=15169
		$Player/Camera2D.limit_left=13185




func _on_Area2D3_body_exited(body):
	if body.name=="Player":
		$Player/Camera2D.limit_bottom=352
		$Player/Camera2D.limit_top=-317
		$Player/Camera2D.limit_right=26000
		$Player/Camera2D.limit_left=0


func _on_Area2D4_body_entered(body):
	if body.name=="Player":
		$Hidden3/AnimationPlayer.play("Hide")
		$Hidden4/AnimationPlayer.play("Hide1")


func _on_Area2D4_body_exited(body):
	if body.name=="Player":pass
