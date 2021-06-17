extends "res://Scripts/Entity.gd"

const Spit=preload("res://Bosses/Spit.tscn")
const wave= preload("res://Bosses/shock_wave.tscn")
const UP = Vector2(0, -1);
const GRAVITY = 100;
const ACCELERATION = 50;
const MAX_SPEED = 250;
const START_SPEED = 150
const JUMP_HEIGHT = -1300;

var direction = 1
var motion = Vector2()
var health = 8
var timer

onready var rng = RandomNumberGenerator.new()
onready var player_push=$Area2D
onready var player_push2=$Area2D2
onready var player_push3=$Area2D3

func _init():
	add_state('idle') #0
	add_state('walk') #1
	add_state('att1') #2
	add_state('att2') #3
	add_state('spit') #4
	add_state('die') #5
	add_state('fake_idle') #6

func _ready():
	if save_data == null:
		set_state(states.fake_idle)
	timer = 0

func _state_logic(_delta):
	timer += _delta
	motion.y += GRAVITY;
	motion = move_and_slide(motion, UP)
	var player_x=get_tree().get_root().get_node("World/Player").global_position.x
	var our_x=global_position.x
	match state:
		states.idle:
			if (our_x > player_x and direction == 1) or (our_x < player_x and direction == -1):
				set_dir(-direction)
		states.walk:
			if (our_x > player_x and direction == 1) or (our_x < player_x and direction == -1):
				set_dir(-direction)
			motion.x = START_SPEED * direction
	
func _get_transition():
	match state:
		states.idle:
			if timer >= 1:
				timer = 0
				if health > 0:
					ch_state1()
		states.walk:
			if timer >= 0.5:
				timer = 0
				if health > 0:
					ch_state1()
	return null
	
func _enter_state(_new_state, _old_state):
	match _new_state:
		states.idle:
			get_node("Hurtbox/CollisionShape2D2").disabled=false
			get_node("AnimationPlayer").play("Idle")
			motion.x=0
			timer = 0
		states.walk:
			get_node("AnimationPlayer").play("Walk")
			timer = 0
		states.att1:
			get_node("AnimationPlayer").play("Att1")
			motion.x=0
		states.att2:
			get_node("AnimationPlayer").play("Att2")
			motion.x=0
		states.die:
			get_node("AnimationPlayer").play("Die")
			$Area2D/CollisionShape2D2.disabled=true
			$Area2D2/CollisionShape2D2.disabled=true
			$Area2D3/CollisionShape2D2.disabled=true
			$Hurtbox/CollisionShape2D2.disabled=true
			motion.x=0
		states.spit:
			get_node("AnimationPlayer").play("Spit")
			motion.x=0
		states.fake_idle:
			get_node("AnimationPlayer").play("Idle")
			motion.x=0
	print(get_state_by_id(_new_state))


func _exit_state(_old_state, _new_state):
	match _old_state:
		states.fake_idle:
			get_node("Hurtbox/CollisionShape2D2").disabled=false
	pass

func set_dir(dir):
	direction = dir
	if dir == -1:
		$Sprite.flip_h=true
		$Sprite/Position2D.position.x=-26
		$Sprite/Position2D2.position.x=-30
		$Area2D2.position.x=-18.184
		$Area2D3.position.x=-34.796
	elif dir == 1:
		$Sprite.flip_h=false
		$Sprite/Position2D.position.x=26
		$Sprite/Position2D2.position.x=30
		$Area2D2.position.x=18.184
		$Area2D3.position.x=34.796


func fire():
	var spit=Spit.instance()
	spit.position=$Sprite/Position2D.global_position
	spit.look_vec=get_tree().get_root().get_node("World/Player").global_position-$Sprite/Position2D.global_position
	get_tree().get_root().get_node("World").add_child(spit)
	
func fire2():
	var bump=wave.instance()
	bump.position=$Sprite/Position2D2.global_position
	bump.dir = direction
	get_tree().get_root().get_node("World").add_child(bump)

func ch_state1():
	var dir=get_tree().get_root().get_node("World/Player").global_position.x
	var our=global_position.x
	rng.randomize()
	var num=rng.randi()%10+1
	if  abs(our - dir)<=90:
		if int(num)<=4:
			set_state(states.att2)
		elif int(num)<=8 and 4<int(num):
			set_state(states.att1)
		elif int(num)<=10 and 8<int(num):
			set_state(states.spit)
	else:
		if int(num)<=8:
			set_state(states.walk)
		elif int(num)<=9 and 8<int(num):
			set_state(states.att1)
		elif int(num)<=10 and 9<int(num):
			set_state(states.spit)

func _on_AnimationPlayer_animation_finished(name):
	if name=="Att1":
		set_state(states.idle)
	if name=="Att2":
		set_state(states.idle)
	if name=="Spit":
		set_state(states.idle)
	if name=="Die":
		get_tree().get_root().get_node("World").unraise()
		queue_free()

func _on_AnimationPlayer_animation_started(name):
	if name=="Att1":
		motion.x=0
	elif name=="Att2":
		motion.x=0
	elif name=="Spit":
		motion.x=0
	elif name=="Idle":
		motion.x=0
	elif name=="Die":
		$Hurtbox.queue_free()
		$Area2D3.queue_free()
		$Area2D.queue_free()
		$Area2D2.queue_free()
		motion.x=0

func _on_Hurtbox_area_entered(_area):
	health=health-1
	if health<=0:
		set_state(states.die)


func get_save_data():
	var data = {
		"direction": direction,
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"state": get_state_by_id(state),
		"health": health
	}
	return data

func set_from_save_data(_data):
	set_dir(_data.direction)
	global_position.x = _data.position.x
	global_position.y = _data.position.y
	set_state(states[_data.state])
	health = _data.health

func get_entity_name():
	return "Old_guardian"
