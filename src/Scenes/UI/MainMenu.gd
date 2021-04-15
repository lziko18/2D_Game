extends MarginContainer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	

func handle_selection(_current_selection):
	pass
	#var emer ='res://'+ str(player_data.scene) +'.tscn'
	#var scene= load(emer)
	#if _current_selection == 0:
	#	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
	#	yield(get_tree().create_timer(1), "timeout")
	#	get_tree().change_scene("res://World.tscn")
	#elif _current_selection == 1:
	#	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
	#	yield(get_tree().create_timer(1), "timeout")
	#	self.queue_free()
	#	var pause_mode = load("res://UI/Pause.tscn")
	#	get_tree().get_root().add_child(pause_mode.instance())
	#	get_tree().get_root().add_child(scene.instance())
		#player.position=Vector2(player_data.position_x,player_data.position_y)#player_data.position
		#get_tree().get_root().get_child(5).add_child(player)
	
	#elif _current_selection == 2:
	#	get_tree().quit()

