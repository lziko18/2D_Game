extends AnimatedSprite






# Called when the node enters the scene tree for the first time.



func _on_Area2D_body_entered(body):
	if body.name=="Player":
		body.speaking_to="Bandit"
		$AnimationPlayer.play_backwards("New Anim")
		body.can_speak=true


func _on_Area2D_body_exited(body):
	if body.name=="Player":
		$AnimationPlayer.play("New Anim")
		body.can_speak=false
