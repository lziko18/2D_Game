extends "res://Scripts/World.gd"
onready var root=get_tree().get_root()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


func refresh():
	$Player/Camera2D.limit_top=-320
	$Player/Camera2D.limit_right=11232
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_left=0
	$Area2D/CollisionShape2D.disabled = false
	yield(get_tree().create_timer(0.05), "timeout")





#func get_ifo():
	#mini.point.x=player.global_position.x
	#mini.koti.x=player.global_position.x
	#mini.point.y=player.global_position.y+40
	#$Timer.start()


#func _on_Timer_timeout():
	#get_ifo()



func raise():
	$Hidden1/AnimationPlayer.play_backwards("New Anim")


func unraise():
	$Hidden1/AnimationPlayer.play("New Anim")
	$Hidden2/AnimationPlayer.play("New Anim")
	yield(get_tree().create_timer(0.3), "timeout")
	var from=$Player/Camera2D.global_position.x
	$Player/Camera2D.change_left(9800,from-1000)
	$Player/Camera2D.change_right(10700,11232)
	yield(get_tree().create_timer(1), "timeout")
	$Player/Camera2D.limit_left=0

	


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
		get_tree().paused=true
		root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		get_tree().paused=false
		body.motion.y = -2000
		yield(get_tree().create_timer(0.1), "timeout")
		body.set_physics_process(false)
		yield(get_tree().create_timer(1), "timeout")
		root.get_node("Game").load_world("World8")
		root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
		body.position=Vector2(13389,800)
		body.motion.y=-1000
		body.motion.x=2000
		body.set_physics_process(true)
		
		#body.motion.y=-1000
		#yield(get_tree().create_timer(0.1), "timeout")
		#body.set_physics_process(false)
		#get_tree().paused=true
		#root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		#get_tree().paused=false
		#yield(get_tree().create_timer(1), "timeout")
		#call_deferred("next_scene")


func _on_Area2D2_body_entered(body):
	if body.name == "Player":
		body.motion.y=1000
		yield(get_tree().create_timer(0.3), "timeout")
		body.motion.y=0
		body.is_casting=false
		body.is_attackig=false
		body.is_air_att=false
		body.is_hooking=false
		body.get_node("Position2D/Chain").release()
		body.is_sliding=false
		body.is_wall_sliding=false
		body.get_node("AnimationPlayer").play("Player Idle")
		body.set_physics_process(false)
		body.can_be_target=false
		get_tree().paused=true
		get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
		get_tree().paused=false
		yield(get_tree().create_timer(0.9), "timeout")
		get_tree().paused=true
		body.position.x = body.last_floor_position.x
		body.position.y = body.last_floor_position.y
		get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
		get_tree().paused=false
		yield(get_tree().create_timer(0.1), "timeout")
		body.set_physics_process(true)
		body.take_damage(1)
		body.motion.x=0
		body.motion.y=0
		yield(get_tree().create_timer(0.5), "timeout")
		body.can_be_target=true


func _on_Area2D3_body_entered(body):
	if body.name=="Player" and get_tree().get_root().get_node("World/Bosses/Old_guardian")!=null:
		var from=$Player/Camera2D.global_position.x
		$Player/Camera2D.change_left(from-1000,9800)
		$Player/Camera2D.limit_right=10700
		raise()
		get_tree().get_root().get_node("World/Bosses/Old_guardian").set_state(0)
		$Area2D3.queue_free()

func _get_world_name():
	return "World9"
