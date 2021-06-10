extends MarginContainer

var saves_list : Array
var menu_items : Array
var current_selected : int
var world_scene = preload("res://Worlds/World8.tscn")
var player_scene = preload("res://Player/Player.tscn")

func _ready():
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	saves_list = SaveSystem.get_saves_list()
	
	menu_items = []
	var menu_item_resource = load("res://UI/Load_Game_Menu/Menu_Item.tscn")
	for save_name in saves_list:
		var menu_item = menu_item_resource.instance()
		menu_item.set_text(save_name)
		$CenterContainer/VBoxContainer.add_child(menu_item)
		menu_items.append(menu_item)
	
	add_input_action("menu_down", KEY_DOWN)
	add_input_action("menu_up", KEY_UP)
	add_input_action("menu_action", KEY_ENTER)
	current_selected = 0
	menu_items[current_selected].select()
	
func add_input_action(name, key):
	InputMap.add_action(name)
	var ev = InputEventKey.new()
	ev.scancode = key
	InputMap.action_add_event(name, ev)

func _input(event):
	if event.is_action_pressed("menu_down"):
		menu_down()
	elif event.is_action_pressed("menu_up"):
		menu_up()
	elif event.is_action_pressed("menu_action"):
		load_game(saves_list[current_selected])

func menu_down():
	menu_items[current_selected].unselect()
	current_selected = (current_selected + 1) % menu_items.size()
	menu_items[current_selected].select()

func menu_up():
	menu_items[current_selected].unselect()
	current_selected = (current_selected - 1) % menu_items.size()
	menu_items[current_selected].select()

func load_game(save : String):
	print("Loading game. "+save)
	var player_data = SaveSystem.load_player(save)
	var world_data = SaveSystem.load_world(save)
	var player_instance = player_scene.instance()
	var world_instance = world_scene.instance()
	player_instance.load_save(player_data)
	world_instance.load_save(world_data)
	world_instance.add_child(player_instance)
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().get_root().add_child(world_instance)
	self.queue_free()
