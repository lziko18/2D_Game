extends KinematicBody2D
export  var direction=1
onready var enemy_stats=$Lizard_stats

var speed=60
const UP=Vector2(0,-1)
var motion= Vector2()
var gravity=30
var state
onready var player_push=$Position2D/Area2D
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


func wander():
	motion.x=150

func _physics_process(delta):
	match state:
		Attack:
			attack_state()
			player_knock_back()
		Wander:
			wander_state(delta)
			$Position2D/Area2D/CollisionShape2D.disabled=true
		Hurt:
			hurt_state(delta)
			$Position2D/Area2D/CollisionShape2D.disabled=true
		Die:
			$CollisionShape2D.disabled=true
			$Hurtbox/CollisionShape2D.disabled=true
			$Position2D/Area2D/CollisionShape2D.disabled=true
			$Position2D/Player_detect/CollisionShape2D.disabled=true
			$backhit/CollisionShape2D.disabled=true
			enemy_death()


func hurt_state(delta):
	motion.y+=gravity
	$Enemyanim.play("en hurt")
	$Position2D/Player_detect/CollisionShape2D.disabled=true
	motion=motion.move_toward(Vector2.ZERO,1000*delta)
	motion= move_and_slide(motion,UP)
	
func wander_state(_delta):
	motion.y+=gravity
	motion= move_and_slide(motion,UP)
	$Enemyanim.play("en walk")
	$Position2D/Player_detect/CollisionShape2D.disabled=true
	$Position2D/Player_detect/CollisionShape2D.disabled=false
	$backhit/CollisionShape2D.disabled=true
	if direction==1:
		$Enemysprite.flip_h=false
		$backhit.position.x=-122.35
		$Hurtbox.position.x=-9.709
		motion.x=speed
		if $RayCast2D.is_colliding() or  !$RayCast2D2.is_colliding():
			direction=-1
			$RayCast2D.rotation_degrees=90
			$RayCast2D2.position.x=-20
			$Hurtbox.position.x*=-1
			if sign($Position2D.position.x)==1:
					$Position2D.position.x*=-1

	elif direction==-1:
		$Enemysprite.flip_h=true
		$backhit.position.x=122.35
		$Hurtbox.position.x=11.986
		motion.x=-speed
		if $RayCast2D.is_colliding() or !$RayCast2D2.is_colliding():
			direction=1
			$RayCast2D.rotation_degrees=-90
			$RayCast2D2.position.x=20
			$Hurtbox.position.x*=-1
			if sign($Position2D.position.x)==-1:
					$Position2D.position.x*=-1

func enemy_death():
	motion.x=0
	motion.y=0
	$Enemyanim.play("en die")

func player_knock_back():
	if $Enemysprite.flip_h==false:
		player_push.knockback_vector=100
	else:
		player_push.knockback_vector=-100



func attack_state():
	motion.x=0
	motion.y+=gravity
	if is_on_floor():
		$backhit/CollisionShape2D.disabled=true
		$Enemyanim.play("En att")
	
	



func _on_Hurtbox_area_entered(area):
	enemy_stats.health-=1
	if enemy_stats.health>0:
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
	if body.can_be_detected==true:
		state=Attack



func _on_Enemyanim_animation_finished(anim_name):
	if anim_name=="En att":
		$Position2D/Player_detect/CollisionShape2D.disabled=true
		$Position2D/Player_detect/CollisionShape2D.disabled=false
		state=Wander
	if anim_name=="en hurt" and is_on_floor():
		state=Wander
	if anim_name=="en die":
		queue_free()


func _on_Player_detect_body_exited(_body):
	state=Wander


func _on_Enemyanim_animation_started(anim_name):
	if anim_name=="En att":
		$Position2D/Player_detect/CollisionShape2D.disabled=true
		$Position2D/Player_detect/CollisionShape2D.disabled=false
	if anim_name=="en hurt":
		$backhit/CollisionShape2D.disabled=false


func _on_backhit_body_entered(_body):
	direction=direction*-1
	if direction==1:
		$RayCast2D.rotation_degrees=-90
		$RayCast2D2.position.x=20
		$Hurtbox.position.x*=-1
		if sign($Position2D.position.x)==-1:
			$Position2D.position.x*=-1
	elif direction==-1:
		$RayCast2D.rotation_degrees=90
		$Hurtbox.position.x=-20
		if sign($Position2D.position.x)==1:
				$Position2D.position.x*=-1


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
