extends "res://Scripts/World.gd"

onready var root=get_tree().get_root()

# Called when the node enters the scene tree for the first time.


func refresh():
	yield(get_tree().create_timer(0.01), "timeout")
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_top=-190
	$Player/Camera2D.limit_right=10300
	$Player/Camera2D.limit_left=0
	yield(get_tree().create_timer(0.05), "timeout")
	print("sbohet")
	$Player.set_physics_process(true)
	$Player/Camera2D/CanvasLayer/Label/AnimationPlayer.play("Hide")
func next_scene_to_world8():
	pass
	#var level = root.get_node(self.name)
	#root.remove_child(level)
	#level.call_deferred("free")
	#var next=load('res://Worlds/World8.tscn')
	#var next_area=next.instance()
	#root.add_child(next_area)
	#var player_inst= load('res://Player/Player.tscn')
	#var player=player_inst.instance()
	#
	#root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	#root.get_child(root.get_child_count()-1).add_child(player)
	#print(root.get_child_count())

func _on_Hide1_area_body_entered(body):
	if body.name=="Player":
		$Hide1/AnimationPlayer.play("Unhide")


func _on_Hide2_area_body_entered(body):
	if body.name=="Player":
		$Hide2/AnimationPlayer.play("Unhide")

func _on_Hide1_area_body_exited(body):
	if body.name=="Player":
		$Hide1/AnimationPlayer.play("Hide")


func _on_Hide2_area_body_exited(body):
	if body.name=="Player":
		$Hide2/AnimationPlayer.play("Hide")


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		get_tree().paused=true
		body.motion.x=1000
		root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		yield(get_tree().create_timer(0.1), "timeout")
		body.set_physics_process(false)
		get_tree().paused=false
		yield(get_tree().create_timer(1), "timeout")
		root.get_node("Game").load_world("World8")
		root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
		#body.position.x = 59
		#body.position.y = 225
		body.position.x = 59
		body.position.y = 225
			
func _get_world_name():
	return "World5"

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
