extends Control

var dialog_of_wizzard = ["Ho... Mukatte kuru no ka... Nigezu ni kono DIO ni chikadzuite kuru no ka....  Sekkaku sofu no Josefu ga watashi no sekai' no shōtai o, shiken shūryō chaimu chokuzen made mondai o hodoite iru jukensei no yōna hisshi koita kibun de oshiete kureta to iu no ni...",
				"Chikadzukanakya teme o buchi nomesenainde na"]
var dialog_of_wizzard2 = ["Pershendetje Alma si po ja kalon ti?"]
var dialog_of_boss= ["So you reached the end!","You thought that now you will receive your 100 points?","HAA FOOL ... If you want your max points you must defeat me first!"]
var dialog_of_bandit= ["Oh, adventurer. We were ambushed by a warrior when we were tryinh to reach the village.",
				"His eyes were red as they were corrupted by pure rage.",
				"I was the only one who clould escape from his hammer.",
				"If you are willing to fight him there is nothing I can do expect wishing you good luck! "]
var dialog_of_bandit2= ["Be carefull and good luck adventurer!"]

var who=""
var dialog
var dialog_index 
var finished 
var wizard=false
var bandit=false
func _ready():
	check_who_are_you_speaking()
	finished = false
	dialog_index = 0
	load_dialog()

func check_who_are_you_speaking():
	if who=="Wizzard" and wizard==false:
		dialog=dialog_of_wizzard
	elif who=="Wizzard" and wizard==true:
		dialog=dialog_of_wizzard2
	elif who=="Boss":
		dialog=dialog_of_boss
	elif who=="Bandit" and bandit==false:
		dialog=dialog_of_bandit
	elif who=="Bandit" and bandit==true:
		dialog=dialog_of_bandit2
	
	

func _process(_delta):
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
		if dialog==dialog_of_wizzard:
			get_tree().get_root().get_node("World/Player").wizard=true
		elif dialog==dialog_of_bandit:
			get_tree().get_root().get_node("World/Player").bandit=true
		elif dialog==dialog_of_boss:
			get_tree().get_root().get_node("World").raise()
			get_tree().get_root().get_node("World/Area2D4").queue_free()
			get_tree().get_root().get_node("World/Bosses/boss_type_01").start()
		get_tree().get_root().get_node("World/Player").cnt=1
		get_tree().get_root().get_node("World/Player").is_speaking=false
		get_parent().queue_free()
	dialog_index += 1

func on_Tween_tween_completed(_object, _key):
	finished = true
