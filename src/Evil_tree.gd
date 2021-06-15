extends KinematicBody2D
export  var direction=1

var speed=100
const UP=Vector2(0,-1)
var motion= Vector2()
var gravity=30
var state
var health=3
var can_move=true
var rng = RandomNumberGenerator.new()
var num
onready var player_push=$Area2D
var player=null
enum{
	Wander,
	Attack,
	Die,
	Idle,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	state=Idle

func _physics_process(delta):
	match state:
		Attack:
			attack_state()
		Wander:
			if $RayCast2D.is_colliding() or  !$RayCast2D2.is_colliding():
				change_dir()
			wander_state(delta)
			motion.y+=gravity
			motion= move_and_slide(motion,UP)
		Die:
			enemy_death()
		Idle:
			idle_state()

func idle_state():
	motion.x=0
	$Enemyanim.play("en idle")


func chose_direction():
	rng.randomize()
	var num=rng.randi()%10+1
	var num1=rng.randi()%10+1
	print(num)
	print(num1)
	if num<=3:
		$Timer.wait_time=1
	elif num>3 and num<=6:
		$Timer.wait_time=2
	else:
		$Timer.wait_time=3
		
	if num1<=5:
		direction=1
	else:
		direction-1
	$Timer.start()

func hurt_state(delta):
	motion.y+=gravity
	$Enemyanim.play("en hurt")
	$Player_detect/CollisionShape2D.disabled=true
	motion= move_and_slide(motion,UP)
	
func wander_state(_delta):
	$Enemyanim.play("en walk")
	$backhit/CollisionShape2D.disabled=true
	if direction==1:
		if can_move==true:
			motion.x=speed
		$Enemysprite.flip_h=true
		$backhit.position.x=-110
		$RayCast2D.scale.y=-1
		$RayCast2D2.position.x=20
		$Area2D.position.x=50
		$Player_detect.position.x=35
	elif direction==-1:
		if can_move==true:
			motion.x=-speed
		$Enemysprite.flip_h=false
		$backhit.position.x=110
		$RayCast2D.scale.y=1
		$RayCast2D2.position.x=-20
		$Area2D.position.x=-50
		$Player_detect.position.x=-35


func enemy_death():
	motion.x=0
	motion.y=0
	$Enemyanim.play("en die")


func change_dir():
	if direction==1:
		direction=-1
	elif direction==-1:
		direction=1

func attack_state():
	motion.x=0
	$Enemyanim.play("En att")
	
	


















func _on_Timer_timeout():
	state=Idle
