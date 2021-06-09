extends Node2D
onready var root=get_tree().get_root()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true
	yield(get_tree().create_timer(0.01), "timeout")
	$Player/Camera2D.limit_top=-317
	$Player/Camera2D.limit_right=11232
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.set_physics_process(true)







#func get_ifo():
	#mini.point.x=player.global_position.x
	#mini.koti.x=player.global_position.x
	#mini.point.y=player.global_position.y+40
	#$Timer.start()


#func _on_Timer_timeout():
	#get_ifo()







func next_scene():
	var level = root.get_node(self.name)
	level.queue_free()
	level.call_deferred("free")
	var next=load('res://Worlds/World8.tscn')
	var next_area=next.instance()
	root.add_child(next_area)
	var player_inst= load('res://Player/Player.tscn')
	var player=player_inst.instance()
	player.position=Vector2(13389,802)
	player.motion.y=-500
	player.motion.x=2000
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	root.get_child(root.get_child_count()-1).add_child(player)
	print(root.get_child_count())


func _on_Area2D_body_entered(body):
		if body.name=="Player":
			body.motion.y=-1000
			yield(get_tree().create_timer(0.1), "timeout")
			body.set_physics_process(false)
			get_tree().paused=true
			root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
			get_tree().paused=false
			yield(get_tree().create_timer(1), "timeout")
			call_deferred("next_scene")
