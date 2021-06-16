extends Sprite

var target1
var target2
var dir=0
const scene = preload("res://Obelisk.tscn")
var can_save=false
func _ready():
	target1=Vector2(global_position.x,global_position.y-10)
	target2=Vector2(global_position.x,global_position.y)
	self.tween_run_1()

func tween_run_1():
	$Tween.interpolate_property(self,"position",target2,target1,2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	dir=1
	$Tween.start()
func backrun():
	$Tween.interpolate_property(self,"position",target1,target2,2,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	dir=0
	$Tween.start()

func _process(delta):
	if Input.is_action_just_pressed("Talk_Read") and can_save==true:
		$Example2/Particles2D.emitting=true
		get_tree().get_root().get_node("Game").save_game("Checkpoint")
		get_tree().get_root().get_node("World/Player").heal(20)
		yield(get_tree().create_timer(0.5), "timeout")
		$Example2/Particles2D.emitting=false



func _on_Tween_tween_all_completed():
	if dir==0:
		tween_run_1()
	else:
		backrun()


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		can_save = true
		if body.obelisk==false:
			var add=scene.instance()
			get_tree().get_root().get_node("World/Player/Camera2D").add_child(add)
			body.obelisk=true
		can_save=true
		body.obelisk=true
	$AnimationPlayer.play("New Anim")


func _on_Area2D_body_exited(body):
	if body.name=="Player":
		$AnimationPlayer.play_backwards("New Anim")


func _on_Timer_timeout():
	can_save=true
