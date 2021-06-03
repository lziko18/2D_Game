extends KinematicBody2D

export  var direction=1

var speed=200
var UP=Vector2(0,-1)
var motion= Vector2()
var gravity=30
var dir
onready var player_push=$Area2D2

# Called when the node enters the scene tree for the first time.
func _ready():
	motion.x=speed
	$Sprite/AnimationPlayer.play("Crawl")

func player_knock_back():
	var dir=get_parent().get_node("Player").global_position.x
	var our=get_parent().get_node("Crawler").global_position.x
	if our<dir:
		player_push.knockback_vector=100
	else:
		player_push.knockback_vector=-100
		
func check():
	if $right.is_colliding() and $down.is_colliding():
		yield(get_tree().create_timer(0.02), "timeout")
		motion.x=0
		motion.y=-speed
		$Sprite.rotation_degrees=-90
	elif $right.is_colliding() and $up.is_colliding():
		yield(get_tree().create_timer(0.02), "timeout")
		motion.x=-speed
		motion.y=0
		$Sprite.rotation_degrees=180
	elif $left.is_colliding() and $down.is_colliding():
		yield(get_tree().create_timer(0.02), "timeout")
		motion.x=speed
		motion.y=0
		$Sprite.rotation_degrees=0
	elif $left.is_colliding() and $up.is_colliding():
		yield(get_tree().create_timer(0.02), "timeout")
		motion.x=0
		motion.y=speed
		$Sprite.rotation_degrees=90
	elif $down.is_colliding() and $up.is_colliding()==false and $right.is_colliding()==false and $left.is_colliding()==false:
		dir="down"
	elif $up.is_colliding() and $down.is_colliding()==false and $right.is_colliding()==false and $left.is_colliding()==false:
		dir="up"
	elif $left.is_colliding() and $up.is_colliding()==false and $right.is_colliding()==false and $down.is_colliding()==false:
		dir="left"
	elif $right.is_colliding() and $up.is_colliding()==false and $down.is_colliding()==false and $left.is_colliding()==false:
		dir="right"

func check2():
	if $right.is_colliding()==false and $up.is_colliding()==false and $down.is_colliding()==false and $left.is_colliding()==false:
		if dir=="down":
			motion.x=0
			motion.y=speed
			$Sprite.rotation_degrees=90
		elif dir=="up":
			motion.x=0
			motion.y=-speed
			$Sprite.rotation_degrees=-90
		elif dir=="left":
			motion.y=0
			motion.x=-speed
			$Sprite.rotation_degrees=180
		elif dir=="right":
			motion.y=0
			motion.x=speed
			$Sprite.rotation_degrees=0


func _physics_process(delta):
	check()
	check2()
	motion=move_and_slide(motion,UP)

func del():
	self.queue_free()

func zise():
	$Sprite.scale.x=3.5
	$Sprite.scale.y=3.5
	if $Sprite.rotation_degrees==0:
		$Sprite.position.x=-40.454
		$Sprite.position.y=-128.547
	elif $Sprite.rotation_degrees==90:
		$Sprite.position.x=128.547
		$Sprite.position.y=-40.454
	elif $Sprite.rotation_degrees==-90:
		$Sprite.position.x=-128.547
		$Sprite.position.y=40.454
	elif $Sprite.rotation_degrees==180:
		$Sprite.position.x=40.454
		$Sprite.position.y=128.547

func _on_Area2D_body_entered(body):
	$Sprite/AnimationPlayer.play("Explode")
	motion.x=0
	motion.y=0
	set_physics_process(false)

