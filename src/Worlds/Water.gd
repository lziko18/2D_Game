tool
extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	_zoom_changed()

func _zoom_changed():
		material.set_shader_param("y_zoom",get_viewport().global_canvas_transform.y.y)

func _on_Sprite5_item_rect_changed():
	material.set_shader_param("scale",scale)
