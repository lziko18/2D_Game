extends Sprite
var target1
var target2
var dir=0
const scene = preload("res://Fireball.tscn")
func _ready():
	if save_data != null:
		set_from_save_data(save_data)
		save_data = null
	$AnimationPlayer.play("New Anim")
	target1=Vector2(global_position.x,global_position.y-10)
	target2=Vector2(global_position.x,global_position.y)
	self.tween_run_1()

func tween_run_1():
	$Tween.interpolate_property(self,"position",target2,target1,2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	dir=1
	$Tween.start()
func backrun():
	$Tween.interpolate_property(self,"position",target1,target2,2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	dir=0
	$Tween.start()




func _on_Tween_tween_all_completed():
	if dir==0:
		tween_run_1()
	else:
		backrun()


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		body.can_cast=true
		if body.spirit_fire==false:
			var add=scene.instance()
			get_tree().get_root().get_node("World/Player/Camera2D").add_child(add)
			body.spirit_fire=true
		queue_free()
		
var save_data = null

func load_save(data):
	save_data = data

func get_save_data():
	var data = {
		"position": {
			"x": global_position.x,
			"y": global_position.y
		}
	}
	return data

func set_from_save_data(data):
	global_position.x = data.position.x
	global_position.y = data.position.y

func get_entity_name():
	return "Flame_spirit"
