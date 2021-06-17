extends Node2D
class_name Game

var world_scenes = {
	"World5": preload("res://Worlds/World5.tscn"),
	"World8": preload("res://Worlds/World8.tscn"),
	"World9": preload("res://Worlds/World9.tscn")
}
var player_scene = preload("res://Player/Player.tscn")

enum LoadType {
	START,
	LOAD,
	TRANSITION,
	RESPAWN
}

var save_data = null

func load_save(save_name):
	save_data = {}
	save_data["player"] = SaveSystem.load_player(save_name)
	save_data["worlds"] = SaveSystem.load_worlds(save_name)

func _ready():
	if save_data == null or not save_data.has("player") or not save_data.has("worlds") or not save_data["player"].has("world_name"):
		save_data = {}
		save_data["player"] = {}
		save_data["worlds"] = {}
		load_world("World8", LoadType.START)
	else:
		load_world(save_data.player.world_name, LoadType.LOAD)

func load_world(world_name, load_type):
	print("Loading "+world_name+" with type "+LoadType.keys()[load_type])
	var root = get_tree().get_root()
	if load_type == LoadType.START:
		var world_instance = world_scenes[world_name].instance()
		var player_instance = player_scene.instance()
		player_instance.world_name = world_name
		player_instance.global_position = world_instance.get_node("Player_Start").global_position
		world_instance.add_child(player_instance)
		root.add_child(world_instance)
		save_game("_respawn")
	elif load_type == LoadType.LOAD:
		var world_instance = world_scenes[world_name].instance()
		world_instance.load_save(save_data.worlds[world_name])
		var player_instance = player_scene.instance()
		player_instance.load_save(save_data.player)
		world_instance.add_child(player_instance)
		root.add_child(world_instance)
	elif load_type == LoadType.TRANSITION:
		var world_instance = world_scenes[world_name].instance()
		#world_instance.load_save(save_data.worlds[world_name])
		var old_world = root.get_node("World")
		var player_instance = old_world.get_node("Player")
		player_instance.world_name = world_name
		old_world.remove_child(player_instance)
		world_instance.add_child(player_instance)
		player_instance.global_position = world_instance.get_node("Player_Start_"+old_world._get_world_name()).global_position
		root.remove_child(old_world)
		old_world.queue_free()
		root.add_child(world_instance)
	elif load_type == LoadType.RESPAWN:
		var old_world = root.get_node("World")
		root.remove_child(old_world)
		old_world.queue_free()
		load_save("_respawn")
		var world_instance = world_scenes[save_data.player.world_name].instance()
		world_instance.load_save(save_data.worlds[save_data.player.world_name], false)
		var player_instance = player_scene.instance()
		player_instance.load_save(save_data.player)
		world_instance.add_child(player_instance)
		root.add_child(world_instance)
	root.get_node("World").refresh()

func save_game(save_name : String):
	var world_node = get_tree().get_root().get_node("World")
	save_data.worlds[world_node._get_world_name()] = world_node.get_save_data()
	var player_node = world_node.get_node("Player")
	save_data.player = player_node.get_save_data()
	print(save_data)
	SaveSystem.save_player(save_name, save_data.player)
	SaveSystem.save_worlds(save_name, save_data.worlds)
