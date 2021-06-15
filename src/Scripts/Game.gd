extends Node2D
class_name Game

var world_scenes = {
	"World5": preload("res://Worlds/World5.tscn"),
	"World8": preload("res://Worlds/World8.tscn"),
	"World9": preload("res://Worlds/World9.tscn")
}

var world_instances = {
	"World5": null,
	"World8": null,
	"World9": null
}

var save_data = null

func load_save(save_name : String):
	save_data = {}
	save_data["player"] = SaveSystem.load_player(save_name)
	save_data["worlds"] = SaveSystem.load_worlds(save_name)

func _ready():
	if save_data != null:
		var player_world = save_data.player.world_name
		load_world(player_world)
	else:
		save_data = {}
		save_data["player"] = {}
		save_data["worlds"] = {}
		load_world("World5")

func load_world(world_name):
	print("loading world " + world_name)

	var root = get_tree().get_root()

	# gen world instance
	var world_instance = null
	if world_instances[world_name] != null:
		world_instance = world_instances[world_name]
	else:
		world_instance = world_scenes[world_name].instance()
		if save_data.worlds.has(world_name):
			world_instance.load_save(save_data.worlds[world_name])

	# gen player instance
	var player_instance = null
	if root.get_node("World") != null:
		player_instance = root.get_node("World/Player")
		root.get_node("World").remove_child(player_instance)
	else:
		player_instance = preload("res://Player/Player.tscn").instance()
		if save_data.player.size() > 0:
			player_instance.load_save(save_data.player)
	
	# save old_world and remove from tree
	var old_world = root.get_node("World")
	if old_world != null:
		world_instances[old_world._get_world_name()] = old_world
		save_data["worlds"][old_world._get_world_name()] = old_world.get_save_data()
		root.remove_child(old_world)
	
	if world_name == "World5" and world_instances["World5"] == null:
		player_instance.global_position = world_instance.get_node("Player_Start").global_position
	#elif world_instances[old_world._get_world_name()] == null:
	#	player_instance.global_position = world_instance.get_node("Player_Start_" + old_world._get_world_name()).global_position
	#if world_instances[world_instance._get_world_name()] == null and world_name == "World5":
	#	player_instance.global_position = world_instance.get_node("Player_Start").global_position
	#elif old_world != null:
	#	player_instance.global_position = world_instance.get_node("Player_Start_" + old_world._get_world_name()).global_position

	# replace old_world with new
	player_instance.world_name = world_name
	world_instance.add_child(player_instance)
	root.add_child(world_instance)

func save_game(save_name : String):
	var world_node = get_tree().get_root().get_node("World")
	save_data.worlds[world_node._get_world_name()] = world_node.get_save_data()
	var player_node = world_node.get_node("Player")
	save_data.player = player_node.get_save_data()
	print(save_data)
	SaveSystem.save_player(save_name, save_data.player)
	SaveSystem.save_worlds(save_name, save_data.worlds)
