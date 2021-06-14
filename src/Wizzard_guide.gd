extends Sprite





# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("New Anim")



func _on_Area2D_body_entered(body):
	if body.name=="Player":
		body.speaking_to="Wizzard"
		$Sprite/AnimationPlayer.play("New Anim")
		body.can_speak=true


func _on_Area2D_body_exited(body):
	if body.name=="Player":
		$Sprite/AnimationPlayer.play_backwards("New Anim")
		body.can_speak=false
