extends Area2D

const Spit=preload("res://Bosses/Spit_blast.tscn")
var move = Vector2.ZERO
var look_vec =Vector2()
var player =null
var speed=20
var  knockback_vector=0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move= Vector2.ZERO
	move=move.move_toward(look_vec,delta)
	move=move.normalized() * speed
	position+=move

func fire():
	var spit=Spit.instance()
	spit.position=global_position
	if move.x>0:
		spit.dir="right"
	else:
		spit.dir="left"
	get_parent().add_child(spit)

func _on_Spit_body_entered(_body):
	fire()
	queue_free()
