extends "res://Scripts/World.gd"

onready var root=get_tree().get_root()

func _ready():
	get_tree().paused=true
	yield(get_tree().create_timer(0.01), "timeout")
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_top=-500
	$Player/Camera2D.limit_right=26000
	$Player/Camera2D.limit_left=0
	get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	get_tree().paused=false
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
		$Player/Camera2D.limit_top=-317
		$Player/Camera2D.limit_right=26000
		$Player/Camera2D.limit_left=0


func _on_Area2D4_body_entered(body):
	if body.name=="Player":
		$Hidden3/AnimationPlayer.play("Hide")
		$Hidden4/AnimationPlayer.play("Hide1")


func _on_Area2D4_body_exited(body):
	if body.name=="Player":pass


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

func _on_FallCollision2_body_entered(body):
	if body.name == "Player":
		body.position.x = body.last_floor_position.x
		body.position.y = body.last_floor_position.y


func _on_FallCollision_body_entered(body):
	if body.name == "Player":
		body.position.x = body.last_floor_position.x
		body.position.y = body.last_floor_position.y
