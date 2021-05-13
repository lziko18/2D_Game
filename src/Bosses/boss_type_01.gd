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
var rng = RandomNumberGenerator.new()
var num



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
	elif our < dir:
		$Sprite.flip_h=false
		$Sprite/Position2D.position.x=8	

func walk():
	if $Sprite.flip_h == true:
		motion.x = -150;
	elif $Sprite.flip_h == false:
		motion.x = 150;







func jumporfall():
	if grounded:
		if Input.is_action_just_pressed("ui_up"):
			motion.y += JUMP_HEIGHT
	if grounded==false:
		if motion.y>0:
			pass

func jump_attack():
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
	motion.x=0
	motion.y=0
	yield(get_tree().create_timer(0.35), "timeout")
	GRAVITY=0
	motion.y=-1000
	yield(get_tree().create_timer(0.15), "timeout")
	motion.y=0
	yield(get_tree().create_timer(0.5), "timeout")
	motion.y=0
func leap_down():
	pass

func choose_state():
	print("from1")
	if can_choose==true:
		rng.randomize()
		num=rng.randf_range(0, 10)
		if int(num)<=2:
			$Node.set_state(0)
		elif int(num)<=8 and 2<int(num):
			$Node.set_state(0)
		elif 8<int(num) and int(num)<=10:
			$Node.set_state(6)
func choose_state2():
	print("from2")
	if can_choose==true:
		rng.randomize()
		num=rng.randf_range(0, 10)
		if int(num)<=2:
			dash=true
			$Node.set_state(5)
		elif int(num)<=5 and 2<int(num):
			dash=true
			$Node.set_state(10)
		elif int(num)<=9 and 5<int(num):
			dash=true
			$Node.set_state(1)
		elif int(num)<=10 and 9<int(num):
			$Node.set_state(6)


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
		GRAVITY=100
		$Node.set_state(11)
	if anim_name=='boss_leap_down':
		$Node.set_state(4)

func get_hammer():
	get_parent().get_child(get_child_count()-1).queue_free()

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
	if anim_name=="boss_spin_att":
		spin()
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
		leap_up()
	elif anim_name=="boss_leap_down":
		position.x=get_parent().get_node("Hammer").position.x
		position.y=get_parent().get_node("Hammer").position.y-10



func _on_att_body_entered(body):
	if $Node.state==4 or $Node.state==0 or $Node.state==1:
		$Node.set_state(7)
