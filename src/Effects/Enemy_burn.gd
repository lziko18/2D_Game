extends AnimatedSprite



func _on_Enemy_burn_animation_finished():
	queue_free()
