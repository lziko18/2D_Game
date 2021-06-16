extends "res://Scripts/World.gd"

onready var root=get_tree().get_root()


func refresh():
	yield(get_tree().create_timer(0.01), "timeout")
	$Area2D3/CollisionShape2D.disabled=true
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_top=-320
	$Player/Camera2D.limit_right=25975
	$Player/Camera2D.limit_left=0
	$Area2D3/CollisionShape2D.disabled=false
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.set_physics_process(true)
	$Area2D3/CollisionShape2D.disabled=false

func next_scene_to_world9():
	var level = root.get_node(self.name)
	root.remove_child(level)
	level.call_deferred("free")
	var next=load('res://Worlds/World9.tscn')
	var next_area=next.instance()
	root.add_child(next_area)
	var player_inst= load('res://Player/Player.tscn')
	var player=player_inst.instance()
	player.position=Vector2(4420,-200)
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	root.get_child(root.get_child_count()-1).add_child(player)
	print(root.get_child_count())
	
func next_scene_to_world5():
	var level = root.get_node(self.name)
	root.remove_child(level)
	level.call_deferred("free")
	var next=load('res://Worlds/World5.tscn')
	var next_area=next.instance()
	root.add_child(next_area)
	var player_inst= load('res://Player/Player.tscn')
	var player=player_inst.instance()
	player.position=Vector2(10251.187,196.382)
	player.get_node("Sprite").flip_h=true
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	root.get_child(root.get_child_count()-1).add_child(player)
	print(root.get_child_count())

func raise():
	$Hidden3/AnimationPlayer.play("Unhide")
	var from=$Player/Camera2D.global_position.x
	print(from)
	$Player/Camera2D.change_left(from-1000,25225)
	
func unraise():
	var from=$Player/Camera2D.global_position.x
	print(from)
	$Hidden3/AnimationPlayer.play("Hide")
	$Hidden4/AnimationPlayer.play("Hide1")
	yield(get_tree().create_timer(0.3), "timeout")
	$Player/Camera2D.change_left(25225,from-1000)
	$Player/Camera2D.change_right(25975,27125)
	yield(get_tree().create_timer(1), "timeout")
	$Player/Camera2D.limit_left=0


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		$Hidden1/AnimationPlayer.play("Unhide")


func _on_Area2D_body_exited(body):
	if body.name=="Player":
		$Hidden1/AnimationPlayer.play("Hide")


func _on_Area2D2_body_entered(body):
	if body.name=="Player":
		$Hidden2/AnimationPlayer.play("Unhide")


func _on_Area2D2_body_exited(body):
	if body.name=="Player":
		$Hidden2/AnimationPlayer.play("Hide")


func _on_Area2D3_body_entered(body):
	if body.name=="Player":
		get_tree().get_root().get_node("World/Player/Light2D").visible=true
		$CanvasModulate.visible=true
		$Player/Camera2D.limit_bottom=864
		$Player/Camera2D.limit_top=351
		$Player/Camera2D.limit_right=15169
		$Player/Camera2D.limit_left=13185


func _on_Area2D3_body_exited(body):
	if body.name=="Player":
		get_tree().get_root().get_node("World/Player/Light2D").visible=false
		$CanvasModulate.visible=false
		$Player/Camera2D.limit_bottom=352
		$Player/Camera2D.limit_top=-320
		$Player/Camera2D.limit_right=25975
		$Player/Camera2D.limit_left=0


func _on_Area2D4_body_entered(body):
	if body.name=="Player":
		body.speaking_to="Boss"
		$Area2D4/Sprite/AnimationPlayer.play("New Anim")
		body.can_speak=true



func _on_Area2D4_body_exited(body):
	if body.name=="Player":
		$Area2D4/Sprite/AnimationPlayer.play_backwards("New Anim")
		body.can_speak=false


func _on_world9_body_entered(body):
	if body.name=="Player":
		get_tree().paused=true
		root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		get_tree().paused=false
		yield(get_tree().create_timer(1), "timeout")
		root.get_node("Game").load_world("World9")
		root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
		body.position.x = 4420
		body.position.y = -200
		#body.motion.y=1000
		#yield(get_tree().create_timer(0.01), "timeout")
		#body.set_physics_process(false)
		#get_tree().paused=true
		#root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		#get_tree().paused=false
		#yield(get_tree().create_timer(1), "timeout")
		#call_deferred("next_scene_to_world9")


func _on_world5_body_entered(body):
	if body.name=="Player":
		get_tree().paused=true
		body.motion.x=-1000
		root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
		yield(get_tree().create_timer(0.1), "timeout")
		body.set_physics_process(false)
		get_tree().paused=false
		yield(get_tree().create_timer(1), "timeout")
		root.get_node("Game").load_world("World5")
		root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
		body.position.x = 10251
		body.position.y = 196
			#body.motion.x=-1000
			#body.set_physics_process(false)
			#get_tree().paused=true
			#root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
			#get_tree().paused=false
			#yield(get_tree().create_timer(1), "timeout")
			#call_deferred("next_scene_to_world5")

func _on_FallCollision2_body_entered(body):
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
		

func _on_FallCollision_body_entered(body):
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
	
func _get_world_name():
	return "World8"
		
		
		





