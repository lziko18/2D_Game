extends Node2D

var save_data = null
var entity_scenes = {
	"Crawler": preload("res://Mobs_and_NPC/Crawler.tscn"),
	"Slime": preload("res://Mobs_and_NPC/Slimes.tscn"),
	"Lizard": preload("res://Mobs_and_NPC/Lizard.tscn"),
	"Guardian": preload("res://Mobs_and_NPC/Guardian.tscn"),
	"Pathfinder": preload("res://Mobs_and_NPC/Pathfinder.tscn")
}

var boss_scenes = {
	"Old_guardian": preload("res://Bosses/Old_guardian.tscn"),
	"boss_type_01": preload("res://Bosses/boss_type_01.tscn")
}

var item_scenes = {
	"Grapling": preload("res://Items/Grapling.tscn"),
	"hearts": preload("res://Items/hearts.tscn"),
	"Rune": preload("res://Items/Rune.tscn")
}

func _ready():
	print("transition")
	get_tree().paused=true
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.set_physics_process(true)
	get_tree().paused=false
	if save_data != null:
		set_from_save_data(save_data)

func load_save(data):
	for e in get_node("Entities").get_children():
		e.queue_free()
	for e in get_node("Bosses").get_children():
		e.queue_free()
	for e in get_node("Items").get_children():
		e.queue_free()
	save_data = data

func get_save_data():
	var entity_data = []
	for e in get_node("Entities").get_children():
		var data = e.get_save_data()
		data.name = e.get_entity_name()
		entity_data.append(data)
	var boss_data = []
	for b in get_node("Bosses").get_children():
		var data = b.get_save_data()
		data.name = b.get_entity_name()
		boss_data.append(data)
	var item_data = []
	for item in get_node("Items").get_children():
		var data = item.get_save_data()
		data.name = item.get_entity_name()
		item_data.append(data)
	var data = {
		"entities" : entity_data,
		"bosses": boss_data,
		"items": item_data
	}
	return data

func set_from_save_data(data):
	for i in range(0, data.entities.size()):
		var entity_instance = entity_scenes[data.entities[i].name].instance()
		entity_instance.load_save(data.entities[i])
		get_node("Entities").add_child(entity_instance)
	for i in range(0, data.bosses.size()):
		var boss_instance = boss_scenes[data.bosses[i].name].instance()
		boss_instance.load_save(data.bosses[i])
		get_node("Bosses").add_child(boss_instance)
	for i in range(0, data.items.size()):
		var item_instance = item_scenes[data.items[i].name].instance()
		item_instance.load_save(data.items[i])
		get_node("Items").add_child(item_instance)

func _get_world_name():
	return "World"
