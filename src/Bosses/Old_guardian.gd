extends KinematicBody2D
const Spit=preload("res://Bosses/Spit.tscn")
const wave= preload("res://Bosses/shock_wave.tscn")
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
var health=2
var is_dead=false
onready var player_push=$Area2D
onready var player_push2=$Area2D2
onready var player_push3=$Area2D3


	

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
		$Sprite/Position2D2.position.x=-30
		$Area2D2.position.x=-18.184
		$Area2D3.position.x=-34.796
	elif our < dir:
		$Sprite.flip_h=false
		$Sprite/Position2D.position.x=26
		$Sprite/Position2D2.position.x=30
		$Area2D2.position.x=18.184
		$Area2D3.position.x=34.796
func player_knock_back():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	if our<dir:
		player_push.knockback_vector=100
		player_push2.knockback_vector=100
		player_push3.knockback_vector=100
	else:
		player_push.knockback_vector=-100
		player_push2.knockback_vector=-100
		player_push3.knockback_vector=-100

func fire():
	var spit=Spit.instance()
	spit.position=$Sprite/Position2D.global_position
	spit.look_vec=get_parent().get_node("Player").global_position-$Sprite/Position2D.global_position
	get_parent().add_child(spit)
	
func fire2():
	var bump=wave.instance()
	bump.position=$Sprite/Position2D2.global_position
	if $Sprite.flip_h==false:
		bump.dir=1
	elif $Sprite.flip_h==true:
		bump.dir=-1
	get_parent().add_child(bump)
func walk():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	if $Sprite.flip_h == true:
		motion.x = -150;
	elif $Sprite.flip_h == false:
		motion.x = 150;
	if  abs(our - dir)<=30:
		motion.x = 0;

func ch_state1():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	rng.randomize()
	num=rng.randi()%10+1
	print(num)
	print("state1")
	if  abs(our - dir)<=90:
		if can_choose==true:
			if int(num)<=4:
				$OG_state.set_state(3)
			elif int(num)<=8 and 4<int(num):
				$OG_state.set_state(2)
			elif int(num)<=10 and 8<int(num):
				$OG_state.set_state(4)
	elif abs(our - dir)>90  :
		if can_choose==true:
			if int(num)<=8:
				$OG_state.set_state(1)
			elif int(num)<=9 and 8<int(num):
				$OG_state.set_state(2)
			elif int(num)<=10 and 9<int(num):
				$OG_state.set_state(4)

func ch_state2():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Old_guardian").global_position.x
	rng.randomize()
	num=rng.randi()%10+1
	print(num)
	print("state2")
	if  abs(our - dir)<=90:
		if can_choose==true:
			$OG_state.set_state(3)
	elif abs(our - dir)>90:
			if int(num)<=7:
				$OG_state.set_state(1)
			elif int(num)<=9 and 7<int(num):
				$OG_state.set_state(4)
			elif int(num)<=10 and 9<int(num):
				$OG_state.set_state(2)


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
	if name=="Die":
		queue_free()



func _on_AnimationPlayer_animation_started(name):
	if name=="Die":
		$Area2D/CollisionShape2D2.disabled=true
		$Area2D2/CollisionShape2D2.disabled=true
		$Area2D3/CollisionShape2D2.disabled=true
		$Hurtbox/CollisionShape2D2.disabled=true
	if name=="Att1":
		motion.x=0
	if name=="Att2":
		motion.x=0
	if name=="Spit":
		motion.x=0
	if name=="Idle":
		motion.x=0






func _on_Hurtbox_area_entered(area):
	health=health-1
	print("jeta=")
	print(health)
	if health<=0:
		can_choose=false
		is_dead=true
