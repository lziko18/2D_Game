extends Node

onready var root=get_tree().get_root()

func _ready():
	get_tree().paused=true
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false



#func get_ifo():
	#mini.point.x=player.global_position.x
	#mini.koti.x=player.global_position.x
	#mini.point.y=player.global_position.y+40
	#$Timer.start()


#func _on_Timer_timeout():
	#get_ifo()





func _on_Area2D2_body_entered(body):
	if body.name=="Player":
		get_tree().paused=true
		root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		get_tree().paused=false
		yield(get_tree().create_timer(1), "timeout")
		call_deferred("next_scene")


func next_scene():
	var level = root.get_node(self.name)
	root.remove_child(level)
	level.call_deferred("free")
	var next=load('res://World2.tscn')
	var next_area=next.instance()
	root.add_child(next_area)
	var player_inst= load('res://Player.tscn')
	var player=player_inst.instance()
	player.position=Vector2(81.317,267.286)
	root.get_child(root.get_child_count()-1).add_child(player)
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	print(root.get_child_count())
