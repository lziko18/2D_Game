class_name SaveSystem

const saves_folder = "user://saves"
const player_save_file_name = "player.json"
const world_save_file_name = "world.json"

static func get_saves_list():
	var saves = []
	var dir = Directory.new()
	
	if dir.dir_exists(saves_folder):
		dir.open(saves_folder)
		dir.list_dir_begin()
		
		var file_name = null
		while file_name != "":
			print(file_name)
			file_name = dir.get_next()
			if dir.current_is_dir() && file_name != '.' && file_name != '..':
				saves.append(file_name)
		dir.list_dir_end()
	else:
		dir.make_dir(saves_folder)
	return saves

static func save_player(save_name : String, data : Dictionary):
	var dir = Directory.new()
	var dir_path = saves_folder + "/" + save_name
	if !dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	var file = File.new()
	file.open(dir_path + "/" +  player_save_file_name, File.WRITE)
	var json_string = JSON.print(data, "\t")
	print(json_string)
	file.store_string(json_string)
	file.close()
	
static func save_world(save_name : String, data : Dictionary):
	var dir = Directory.new()
	var dir_path = saves_folder + "/" + save_name
	if !dir.dir_exists(dir_path):
		dir.make_dir_recursive(dir_path)
	var file = File.new()
	file.open(dir_path + "/" +  world_save_file_name, File.WRITE)
	var json_string = JSON.print(data, "\t")
	print(json_string)
	file.store_string(json_string)
	file.close()

static func load_player(save_name : String):
	print("Loading player data.")
	var dir = Directory.new()
	var dir_path = saves_folder + "/" + save_name
	if dir.dir_exists(dir_path):
		var file = File.new()
		file.open(dir_path + "/" +  player_save_file_name, File.READ)
		var data = JSON.parse(file.get_as_text()).result
		file.close()
		print("Player data loaded.")
		return data
	else:
		print("Could not find save files for " + save_name)
		return {}

static func load_world(save_name : String):
	print("Loading player data.")
	var dir = Directory.new()
	var dir_path = saves_folder + "/" + save_name
	if dir.dir_exists(dir_path):
		var file = File.new()
		file.open(dir_path + "/" +  world_save_file_name, File.READ)
		var data = JSON.parse(file.get_as_text()).result
		file.close()
		print("Player data loaded.")
		return data
	else:
		print("Could not find save files for " + save_name)
		return {}
