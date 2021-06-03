extends HBoxContainer

func _ready():
	pass
	
func set_text(text : String):
	$Text.text = text

func select():
	$Selected.text = ">"

func unselect():
	$Selected.text = " "

func is_selected():
	return $Selected.text == ">"
