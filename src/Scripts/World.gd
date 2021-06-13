extends Node2D

var save_data = null
var entity_scenes = {
	"Crawler": preload("res://Mobs_and_NPC/Crawler.tscn"),
	"Slime": preload("res://Mobs_and_NPC/Slimes.tscn"),
	"Lizard": preload("res://Mobs_and_NPC/Lizard.tscn"),
	"Guardian": preload("res://Mobs_and_NPC/Guardian.tscn"),
	"Pathfinder": preload("res://Mobs_and_NPC/Pathfinder.tscn")
}

func _ready():
	if save_data != null:
		set_from_save_data(save_data)

func load_save(data):
	for e in get_node("Entities").get_children():
		e.queue_free()
	save_data = data

func get_save_data():
	var entity_data = []
	for e in get_node("Entities").get_children():
		var data = e.get_save_data()
		data.name = e.get_entity_name()
		entity_data.append(data)
	var data = {
		"entities" : entity_data,
	}
	return data

func set_from_save_data(data):
	for i in range(0, data.entities.size()):
		var entity_instance = entity_scenes[data.entities[i].name].instance()
		entity_instance.load_save(data.entities[i])
		get_node("Entities").add_child(entity_instance)
