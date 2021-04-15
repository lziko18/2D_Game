extends CenterContainer

var label_name: Label = null
var label_selection: Label = null

func _ready():
	label_name = get_node("Container/Name")
	label_selection = get_node("Container/Selection")
	
func set_text(text: String):
	label_name.text = text
	
func set_selected(selected: bool):
	if selected:
		label_selection.text = ">"
	else:
		label_selection.text = ""

