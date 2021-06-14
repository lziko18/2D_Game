extends CanvasLayer



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused =! get_tree().paused
	set_process(false)
	$Tween.interpolate_property($TextureRect/Sprite,"modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused=false
		self.queue_free()

func _on_Tween_tween_all_completed():
	$Tween2.interpolate_property($TextureRect/RichTextLabel2, "percent_visible", 0, 1, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween2.start()




func _on_Tween2_tween_all_completed():
	$Tween3.interpolate_property($TextureRect/Sprite2,"modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween3.start()
	

func _on_Tween3_tween_all_completed():
	$Tween4.interpolate_property($TextureRect/RichTextLabel, "percent_visible", 0, 1, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween4.start()


func _on_Tween4_tween_all_completed():
		$Tween5.interpolate_property($Label, "percent_visible", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween5.start()



func _on_Tween5_tween_all_completed():
		set_process(true)


