extends AnimatedSprite

func _on_Dust_animation_finished():
	queue_free()
