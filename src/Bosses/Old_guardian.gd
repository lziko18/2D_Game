extends KinematicBody2D
const Spit=preload("res://Bosses/Spit.tscn")
const UP = Vector2(0, -1);
var GRAVITY = 100;
const ACCELERATION = 50;
const MAX_SPEED = 250;
const JUMP_HEIGHT = -1300;
var jump_attack=false
var motion = Vector2()
var grounded = false
var attack=false
var can_choose=true
var attack2=false
var attack3=false
var rng = RandomNumberGenerator.new()
var num




func gravity():
	motion.y += GRAVITY;
	grounded = true if is_on_floor() else false;
	motion = move_and_slide(motion, UP)

func change_dir():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	if our > dir:
		$Sprite.flip_h=true
		$Sprite/Position2D.position.x=-26
	elif our < dir:
		$Sprite.flip_h=false
		$Sprite/Position2D.position.x=26


func fire():
	var spit=Spit.instance()
	spit.position=$Sprite/Position2D.global_position
	spit.look_vec=get_parent().get_node("Player").global_position-$Sprite/Position2D.global_position
	get_parent().add_child(spit)
	

func walk():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	if $Sprite.flip_h == true:
		motion.x = -150;
	elif $Sprite.flip_h == false:
		motion.x = 150;
	if  abs(our - dir)<=30:
		motion.x = 0;


func _on_AnimationPlayer_animation_finished(name):
	if name=="Att1":
		$OG_state.set_state(0)
		attack=false
	if name=="Att2":
		$OG_state.set_state(0)
		attack2=false
	if name=="Spit":
		attack3=false
		$OG_state.set_state(0)



func _on_AnimationPlayer_animation_started(name):
	if name=="Att1":
		motion.x=0
	if name=="Att2":
		motion.x=0
	if name=="Spit":
		motion.x=0
	if name=="Idle":
		motion.x=0
