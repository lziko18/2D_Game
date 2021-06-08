extends KinematicBody2D
const Spit=preload("res://Bosses/earthbump.tscn")
var move = Vector2.ZERO
var dir
var speed=10




func _ready():
	if dir==1:
		$RayCast2D.rotation_degrees=-90
	elif dir==-1:
		$RayCast2D.rotation_degrees=90


func _physics_process(delta):
	move= Vector2.ZERO
	move=move.move_toward(Vector2(dir,0),delta)
	move=move.normalized() * speed
	position+=move
	if $RayCast2D.is_colliding()==true:
		queue_free()

func fire():
	var spit=Spit.instance()
	spit.position=global_position
	if dir==1:
		spit.flip_h=false
	elif dir==-1:
		spit.flip_h=true
	get_parent().add_child(spit)



func _on_Timer_timeout():
	fire()
