extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Tween.interpolate_property($Label,"modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


