extends KinematicBody2D
const Hammer = preload("res://Bosses/Hammer.tscn")
const Dust=preload("res://Bosses/Boss_jump.tscn")
const UP = Vector2(0, -1);
var GRAVITY = 100;
const ACCELERATION = 50;
const MAX_SPEED = 250;
const JUMP_HEIGHT = -1300;
var jump_attack=false
var motion = Vector2()
var grounded = false
var spin_attack=false
var dash=false
var attack=false
var leap=false
var dust_pos
var dust_dir
var can_choose=true
var attack_2=false
var rng = RandomNumberGenerator.new()
var num
var dash_con=false
var spin_con=false
var health=1
var is_dead=false
onready var player_push=$Sprite/Position2D/Area2D
onready var player_push2=$Sprite/Position2D/Area2D2
onready var player_push3=$Sprite/Position2D/Area2D3


func gravity():
	motion.y += GRAVITY;
	grounded = true if is_on_floor() else false;
	motion = move_and_slide(motion, UP)
	
func dash():
	if dash==true:
		if $Sprite.flip_h == false :
			motion.x=500 
		elif $Sprite.flip_h == true :
			motion.x=-500
	
func change_dir():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("boss_type_01").global_position.x
	if our > dir:
		$Sprite.flip_h=true
		$Sprite/Position2D.position.x=-8
		$Sprite/Position2D/Area2D.position.x=8.177
		$Sprite/Position2D/Area2D2.position.x=-11.579
		$Sprite/Position2D/Area2D3.position.x=-4.508
	elif our < dir:
		$Sprite.flip_h=false
		$Sprite/Position2D.position.x=8
		$Sprite/Position2D/Area2D.position.x=-8.177
		$Sprite/Position2D/Area2D2.position.x=11.579
		$Sprite/Position2D/Area2D3.position.x=4.508

func player_knock_back():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("boss_type_01").global_position.x
	if our<dir:
		player_push.knockback_vector=100
		player_push2.knockback_vector=100
		player_push3.knockback_vector=100
	else:
		player_push.knockback_vector=-100
		player_push2.knockback_vector=-100
		player_push3.knockback_vector=-100
		
func walk():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("boss_type_01").global_position.x
	if $Sprite.flip_h == true:
		motion.x = -150;
	elif $Sprite.flip_h == false:
		motion.x = 150;
	if  abs(our - dir)<=30:
		motion.x = 0;

func start():
	$Node.set_state(13)






func jump_attack():
	if is_dead==false:
		motion.y += JUMP_HEIGHT
		if $Sprite.flip_h == false :
			motion.x=800 
		elif $Sprite.flip_h == true :
			motion.x=-800

func spin():
	yield(get_tree().create_timer(0.3), "timeout")
	if $Sprite.flip_h == false :
			motion.x=600 
	elif $Sprite.flip_h == true :
			motion.x=-600

func leap_up():
	set_collision_mask_bit(1,false)
	motion.x=0
	motion.y=0
	yield(get_tree().create_timer(0.35), "timeout")
	GRAVITY=0
	if is_dead==false:
		motion.y=-1000
	yield(get_tree().create_timer(0.15), "timeout")
	motion.y=0
	yield(get_tree().create_timer(0.5), "timeout")
	motion.y=0
func leap_down():
	pass


func choose_state_from_distance():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("boss_type_01").global_position.x
	rng.randomize()
	num=rng.randi()%10+1

	if  abs(our - dir)<=120:
		if can_choose==true:
			if int(num)<=2:
				$Node.set_state(6)
			else:
				if attack_2==false:
					$Node.set_state(7)
				elif attack_2==true:
					$Node.set_state(8)
	elif abs(our - dir)>120 and abs(our - dir)<=450 :
		if can_choose==true:
			dash=true
			if int(num)<=1:
				$Node.set_state(4)
			elif int(num)<=2 and 1<int(num):
				$Node.set_state(6)
			elif int(num)<=7 and 2<int(num):
				$Node.set_state(0)
			elif 7<int(num) and int(num)<=9:
				$Node.set_state(10)
			elif int(num)<=10 and 9<int(num):
				$Node.set_state(5)
	elif abs(our - dir)>450 :
		if can_choose==true:
			dash=true
			$Node.set_state(1)




func throw():
	var hammer=Hammer.instance()
	var position_of_hammer=$Sprite/Position2D.global_position
	hammer.position=position_of_hammer
	if abs(get_parent().get_node("Player").get_node("Colli2").global_position.x-$Sprite/Position2D.global_position.x)<200:
		hammer.speed=(get_parent().get_node("Player").get_node("Colli2").global_position.x-$Sprite/Position2D.global_position.x)*3
		hammer.speed2=(336.049-$Sprite/Position2D.global_position.y-25)*3
	else:
		hammer.speed=get_parent().get_node("Player").get_node("Colli2").global_position.x-$Sprite/Position2D.global_position.x
		hammer.speed2=336.049-$Sprite/Position2D.global_position.y-40
	get_parent().add_child(hammer)



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="boss_jump_down":
		$Node.set_state(4)
	if anim_name=="boss_spin_att":
		motion.x=0
		spin_attack=false
		$Node.set_state(4)
	if anim_name=="boss_jump_charge":
		jump_attack=false
		$Node.set_state(2)
		jump_attack()
	if anim_name=="boss_dash":
		dash=false
		$Node.set_state(4)
	if anim_name=='boss_att_01' or anim_name=='boss_att_02' or anim_name=='boss_att_03':
		attack=false
		$Node.set_state(4)
	if anim_name=='boss_leap_up':
		if is_dead==false:
			GRAVITY=100
			$Node.set_state(11)
	if anim_name=='boss_leap_down':
		$Node.set_state(4)
	if anim_name=='boss_taunt':
		$Hurtbox/CollisionShape2D2.disabled=false
		$Node.set_state(4)
	if anim_name=='boss_death':
		get_tree().get_root().get_node("World").unraise()
		queue_free()

func get_hammer():
	pass

func get_pos():
	dust_pos=Vector2(get_parent().get_node("boss_type_01").global_position.x,get_parent().get_node("boss_type_01").global_position.y-20)
	if $Sprite.flip_h==true:
		dust_dir=-1
	elif $Sprite.flip_h==false:
		dust_dir=1
func spawn_dust():
	var dust=Dust.instance()
	dust.position=dust_pos
	if dust_dir==-1:
		dust.flip_h=true
	elif dust_dir==1:
		dust.flip_h=false
	get_parent().add_child(dust)
	
	


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name=='boss_death':
		can_choose=false
	if anim_name=="boss_spin_att":
		spin()
	if anim_name=="boss_death":
		$Hurtbox/CollisionShape2D2.disabled=true
		$Sprite/Position2D/Area2D/CollisionShape2D2.disabled=true
		$Sprite/Position2D/Area2D2/CollisionShape2D2.disabled=true
		$Sprite/Position2D/Area2D3/CollisionShape2D2.disabled=true
	elif anim_name=="boss_dash":
		dash()
	elif anim_name=="boss_att_01" or anim_name=="boss_att_02" or anim_name=="boss_att_03":
		motion.x=0
		yield(get_tree().create_timer(0.25), "timeout")
		if $Sprite.flip_h == false :
			motion.x=600 
		elif $Sprite.flip_h == true :
			motion.x=-600
		yield(get_tree().create_timer(0.1), "timeout")
		motion.x=0
	elif anim_name=="boss_leap_up":
		if is_dead==false:
			leap_up()
	elif anim_name=="boss_leap_down":
		position.x=get_parent().get_node("Hammer").position.x
		position.y=get_parent().get_node("Hammer").position.y-10





func _on_Hurtbox_area_entered(area):
	health=health-1
	print(health)
	if health<=0:
		can_choose=false
		is_dead=true

