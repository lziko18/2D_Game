extends VBoxContainer

class_name MenuItem, "res://UI/MenuItem.gd"

var menu_items: Array = []
var selected_item: int = 0

func _ready():
	menu_items = get_children()
	for menu_item in menu_items:
		menu_item.set_text(menu_item.name)
	menu_items[selected_item].set_selected(true)
	
	InputMap.add_action("menu_down")
	var ev_down = InputEventKey.new()
	ev_down.scancode = KEY_DOWN
	InputMap.action_add_event("menu_down", ev_down)
	
	InputMap.add_action("menu_up")
	var ev_up = InputEventKey.new()
	ev_up.scancode = KEY_UP
	InputMap.action_add_event("menu_up", ev_up)
	
func _input(event: InputEvent):
	if event.is_action_pressed("menu_down"):
		next_item()
	elif event.is_action_pressed("menu_up"):
		previous_item()
		

func next_item():
	menu_items[selected_item].set_selected(false)
	selected_item += 1
	if selected_item == menu_items.size():
		selected_item -= menu_items.size()
	menu_items[selected_item].set_selected(true)
	
func previous_item():
	menu_items[selected_item].set_selected(false)
	selected_item -= 1
	if selected_item == -1:
		selected_item += menu_items.size()
	menu_items[selected_item].set_selected(true)
	
	
