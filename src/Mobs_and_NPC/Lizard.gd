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
var is_attacking=false
enum{
	Wander,
	Attack,
	Hurt,
	Die,
}

var save_data = null
func load_save(data):
	save_data = data

# Called when the node enters the scene tree for the first time.
func _ready():
	state=Wander
	if save_data != null:
		set_from_save_data(save_data)


func _physics_process(delta):
	match state:
		Attack:
			attack_state()
			player_knock_back()
		Wander:
			if $RayCast2D.is_colliding() or  !$RayCast2D2.is_colliding():
				change_dir()
			wander_state(delta)
			motion.y+=gravity
			motion= move_and_slide(motion,UP)
			$Area2D/CollisionShape2D.disabled=true
			
		Hurt:
			hurt_state(delta)
			$Area2D/CollisionShape2D.disabled=true
		Die:
			$CollisionShape2D.disabled=true
			$Hurtbox/CollisionShape2D.disabled=true
			$Area2D/CollisionShape2D.disabled=true
			$Player_detect/CollisionShape2D.disabled=true
			$backhit/CollisionShape2D.disabled=true
			enemy_death()




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

func player_knock_back():
	if player == null:
		player = get_tree().get_root().get_node("World/Player")
	var dir = player.global_position.x
	var our = global_position.x
	if our<dir:
		$Area2D.knockback_vector=100
	else:
		$Area2D.knockback_vector=-100

func change_dir():
	if direction==1:
		direction=-1
	elif direction==-1:
		direction=1

func attack_state():
	motion.x=0
	if is_on_floor():
		$backhit/CollisionShape2D.disabled=true
		if is_attacking==false:
			is_attacking=true
			$Enemyanim.play("En att")
			
	
	



func _on_Hurtbox_area_entered(area):
	health=health-1
	if health>0:
		state=Hurt
	else:
		state=Die
	if area.name=="Att_hitbox":
		motion.x=area.knockback_vector 
	elif area.name=="Ground_slam_hitbox":
		motion.y=area.knockback_vector
		if area.player_position>position.x:
			if area.player_position-position.x<10 && area.player_position-position.x>-10:
				motion.x=0
			else:
				motion.x=area.knockback_vector
		elif area.player_position<position.x:
			if area.player_position-position.x<10 && area.player_position-position.x>-10:
				motion.x=0
			else:
				motion.x=-area.knockback_vector




func _on_Player_detect_body_entered(body):
	if body.name=="Player":
		can_move=false
		motion.x=0
		state=Attack



func _on_Enemyanim_animation_finished(anim_name):
	if anim_name=="En att":
		is_attacking=false
		if can_move==false:
			state=Attack
		elif can_move==true:
			state=Wander
	if anim_name=="en hurt" and is_on_floor():
		state=Wander
	if anim_name=="en die":
		queue_free()





func _on_Enemyanim_animation_started(anim_name):
	if anim_name=="en hurt":
		$backhit/CollisionShape2D.disabled=false


func _on_backhit_body_entered(_body):
	direction=direction*-1


func _on_Player_detect_body_exited(body):
		if body.name=="Player":
			can_move=true

func _on_Lizard_stats_no_health():
	state=Die

func get_save_data():
	var data = {
		"position": {
			"x": global_position.x,
			"y": global_position.y
		}
	}
	return data
	
func set_from_save_data(data):
	global_position.x = data.position.x
	global_position.y = data.position.y

func get_entity_name():
	return "Lizard"
