extends Area2D


var HitEffect= load("res://Effects/Hit_effect.tscn")
var FireEffect= load("res://Effects/Enemy_burn.tscn")


func _on_Hurtbox_area_entered(area):
	if area.name=='Fireball':
		var effect1 = FireEffect.instance()
		get_tree().get_root().add_child(effect1)
		effect1.playing=true
		if area.direction==1:
			effect1.flip_h=false
			effect1.global_position=global_position +Vector2(-10,0)
		elif area.direction==-1:
			effect1.flip_h=true
			effect1.global_position=global_position +Vector2(10,0)
	else:
		var effect = HitEffect.instance()
		get_tree().get_root().add_child(effect)
		effect.playing=true
		effect.global_position=global_position +Vector2(0,3)



