extends "res://Scripts/StateMachine.gd"

var save_data = null

func _ready():
	if save_data != null:
		set_from_save_data(save_data)

func load_save(data):
	save_data = data

func get_save_data():
	pass

func set_from_save_data(data):
	pass

func get_entity_name():
	return "Entity"