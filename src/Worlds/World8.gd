extends Node2D

onready var root=get_tree().get_root()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var entities = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused=true
	yield(get_tree().create_timer(0.01), "timeout")
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_top=-320
	$Player/Camera2D.limit_right=25975
	$Player/Camera2D.limit_left=0
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.set_physics_process(true)
	$Area2D3/CollisionShape2D.disabled=false
	entities = []
	for i in range(0, get_node("Entities").get_child_count()):
		entities.append(true)
	if save_data != null:
		set_from_save_data(save_data)

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
	$StaticBody2D/CollisionShape2D.disabled=false
	$Player/Camera2D.change_left(0,25975)
	
func unraise():
	$Hidden3/AnimationPlayer.play("Hide")
	$Hidden4/AnimationPlayer.play("Hide1")
	yield(get_tree().create_timer(0.3), "timeout")
	$Player/Camera2D.limit_left=0
	$Player/Camera2D.limit_right=27125
	$StaticBody2D/CollisionShape2D.disabled=true
	$StaticBody2D2/CollisionShape2D.disabled=true
	

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
		$Player/Camera2D.limit_bottom=864
		$Player/Camera2D.limit_top=351
		$Player/Camera2D.limit_right=15169
		$Player/Camera2D.limit_left=13185




func _on_Area2D3_body_exited(body):
	if body.name=="Player":
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
			body.motion.y=1000
			yield(get_tree().create_timer(0.01), "timeout")
			body.set_physics_process(false)
			get_tree().paused=true
			root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
			get_tree().paused=false
			yield(get_tree().create_timer(1), "timeout")
			call_deferred("next_scene_to_world9")


func _on_world5_body_entered(body):
	if body.name=="Player":
			body.motion.x=-1000
			body.set_physics_process(false)
			get_tree().paused=true
			root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
			get_tree().paused=false
			yield(get_tree().create_timer(1), "timeout")
			call_deferred("next_scene_to_world5")

var save_data = null

func load_save(data):
	save_data = data

func get_save_data():
	print(entities)
	var entities_to_save = []
	var counter = 0
	for e in entities:
		if e:
			entities_to_save.append(get_node("Entities").get_child(counter).get_save_data())
			counter += 1
		else:
			entities_to_save.append(null)
	var data = {
		"entities" : entities_to_save,
	}
	return data

func set_from_save_data(data):
	for i in range(0, get_node("Entities").get_child_count()):
		if data.entities[i] != null:
			get_node("Entities").get_child(i).set_from_save_data(data.entities[i])
		else:
			entities[i] = false
	for i in range(0, entities.size()):
		if not entities[i]:
			get_node("Entities").get_child(i).queue_free()
	


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
		
		


func _on_Area2D5_body_entered(body):
	
	$Player/Camera2D.limit_left=4000
