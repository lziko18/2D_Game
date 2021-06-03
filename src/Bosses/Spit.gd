extends Area2D


var move = Vector2.ZERO
var look_vec =Vector2()
var player =null
var speed=20




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move= Vector2.ZERO
	move=move.move_toward(look_vec,delta)
	move=move.normalized() * speed
	position+=move


func _on_Spit_body_entered(body):
	queue_free()
