class_name SaveSystem

const saves_folder = "user://saves"
const player_save_file_name = "player.json"

static func get_saves_list():
	var saves = []
	var dir = Directory.new()
	
	if dir.dir_exists(saves_folder):
		dir.list_dir_begin()
		
		var file_name = ""
		while file_name != "":
			file_name = dir.get_next()
			if dir.current_is_dir():
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
	file.store_string(JSON.print(data, "\t"))
	file.close()

static func load_player(save_name : String):
	var dir = Directory.new()
	var dir_path = saves_folder + "/" + save_name
	if dir.dir_exists(dir_path):
		var file = File.new()
		file.open(dir_path + "/" +  player_save_file_name, File.WRITE)
		var data = JSON.parse(file.get_as_text())
		file.close()
		return data
	else:
		print("Could not find save files for " + save_name)
		return {}
