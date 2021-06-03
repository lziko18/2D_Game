extends MarginContainer

var saves_list : Array

func _ready():
	saves_list = SaveSystem.get_saves_list()
	saves_list.append("Test")
	var menu_item_resource = load("res://UI/Load_Game_Menu/Menu_Item.tscn")
	for save_name in saves_list:
		var menu_item = menu_item_resource.instance()
		menu_item.set_text(save_name)
		$CenterContainer/VBoxContainer.add_child(menu_item)
