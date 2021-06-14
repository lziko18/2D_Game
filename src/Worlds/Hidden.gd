extends "res://Scripts/World.gd"

onready var root=get_tree().get_root()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/Camera2D.limit_bottom=352
	$Player/Camera2D.limit_top=-190
	$Player/Camera2D.limit_right=10300
	$Player/Camera2D.limit_left=0
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.set_physics_process(true)
	$Player/Camera2D/CanvasLayer/Label/AnimationPlayer.play("Hide")

func next_scene_to_world8():
	var level = root.get_node(self.name)
	root.remove_child(level)
	level.call_deferred("free")
	var next=load('res://Worlds/World8.tscn')
	var next_area=next.instance()
	root.add_child(next_area)
	var player_inst= load('res://Player/Player.tscn')
	var player=player_inst.instance()
	player.position=Vector2(58.603,228.465)
	root.get_node("/root/Transition").get_node("Transition/Video").play_backwards("transition")
	root.get_child(root.get_child_count()-1).add_child(player)
	print(root.get_child_count())







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
			body.motion.x=1000
			body.set_physics_process(false)
			get_tree().paused=true
			root.get_node("/root/Transition").get_node("Transition/Video").play("transition")
			get_tree().paused=false
			yield(get_tree().create_timer(1), "timeout")
			call_deferred("next_scene_to_world8")
			
func _get_world_name():
	return "World5"
