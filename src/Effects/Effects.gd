extends AnimatedSprite
func _on_AnimatedSprite_animation_finished():
	queue_free()


func _on_Fire_effect_animation_finished():
	queue_free()
