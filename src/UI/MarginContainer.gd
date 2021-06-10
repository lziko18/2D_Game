extends MarginContainer
const SAVE_DIR = "user://saves/"

var save_path = SAVE_DIR + "save.dat"
onready var selector_one = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer/HBoxContainer/Label
onready var selector_two = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer2/HBoxContainer/Label
onready var selector_three = $CenterContainer/VBoxContainer/CenterContainer2/VBoxContainer/CenterContainer3/HBoxContainer/Label
var player_inst= load('res://Player/Player.tscn')
var player=player_inst.instance()
var current_selection = 0
var player_data

func _ready():
	set_current_selection(0)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
		if error == OK:
			player_data = file.get_var()
			print(player_data)
			file.close()

func _process(_delta):
	if Input.is_action_just_pressed("ui_down") and current_selection < 2:
		current_selection += 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_up") and current_selection > 0:
		current_selection -= 1
		set_current_selection(current_selection)
	elif Input.is_action_just_pressed("ui_accept"):
		handle_selection(current_selection)

func handle_selection(_current_selection):
	var emer ='res://Worlds/'+ str(player_data.scene) +'.tscn'
	var scene= load(emer)
	if _current_selection == 0:
		get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
		yield(get_tree().create_timer(1), "timeout")
		self.queue_free()
		var pause_mode = load("res://UI/Game_UI/Pause.tscn")
		get_tree().get_root().add_child(pause_mode.instance())
		get_tree().get_root().add_child((load('res://Worlds/World8.tscn')).instance())
		player.position=Vector2(2800,-79)#player_data.position
		player.set_from_save_data(SaveSystem.load_player("Test2"))
		get_tree().get_root().get_child(5).add_child(player)
		
	elif _current_selection == 1:
		var load_game_menu_scene = load("res://UI/Load_Game_Menu/Load_Game_Menu.tscn")
		var load_game_menu = load_game_menu_scene.instance()
		get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
		yield(get_tree().create_timer(1), "timeout")
		self.queue_free()
		get_tree().get_root().add_child(load_game_menu)
		
	
	elif _current_selection == 2:
		get_tree().quit()

func set_current_selection(_current_selection):
	current_selection = _current_selection
	selector_one.text = ""
	selector_two.text = ""
	selector_three.text = ""
	if _current_selection == 0:
		selector_one.text = ">"
	elif _current_selection == 1:
		selector_two.text = ">"
	elif _current_selection == 2:
		selector_three.text = ">"
