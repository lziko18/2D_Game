extends Sprite

var target1
var target2
var dir=0
# Called when the node enters the scene tree for the first time.
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




func _on_Tween_tween_all_completed():
	if dir==0:
		tween_run_1()
	else:
		backrun()


func _on_Area2D_body_entered(body):
	if body.name=="Player":
		body.add_health(1)
		queue_free()
