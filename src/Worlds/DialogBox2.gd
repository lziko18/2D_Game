extends Control

var dialog = ["Ho... Mukatte kuru no ka... Nigezu ni kono DIO ni chikadzuite kuru no ka....  Sekkaku sofu no Josefu ga watashi no sekai' no shōtai o, shiken shūryō chaimu chokuzen made mondai o hodoite iru jukensei no yōna hisshi koita kibun de oshiete kureta to iu no ni...",
				"Chikadzukanakya teme o buchi nomesenainde na"]
var characters = ["Dio", "Jotaro"]

var dialog_index 
var finished 

func _ready():
	finished = false
	dialog_index = 0
	load_dialog()


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		load_dialog()

func load_dialog():
	if dialog_index < dialog.size():
		finished = false
		$RichTextLabel.bbcode_text = dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$RichTextLabel, "percent_visible", 0, 1, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		get_tree().get_root().get_node("World/Player").is_speaking=false
		get_parent().queue_free()
	dialog_index += 1

func on_Tween_tween_completed(object, key):
	finished = true
