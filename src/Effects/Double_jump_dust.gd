extends AnimatedSprite



func _on_AnimatedSprite_animation_finished():
	queue_free()
