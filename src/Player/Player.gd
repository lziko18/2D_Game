extends KinematicBody2D

# This script controls players movement
const Fireball = preload("res://Skills/Fireball.tscn")
const Dust_jump = preload("res://Effects/Dust.tscn")
const Double_jump_dust=preload("res://Effects/Double_jump_dust.tscn")
const UP=Vector2(0,-1)
const CHAIN_PULL = 105
var can_be_detected=true
var motion=Vector2()

var speed=50
var max_speed=300
var jump_force=600
var gravity=30
var double_jump_force= 500
var jumps_left=0
var attack_points=3
var air_att_points=3
var double_jump=false
var friction=true
var is_casting=false
var is_running=null
var is_jumping=null
var first_jump=true
var can_cast=true
var is_sliding=false
var is_attackig=false
var is_air_att=false
var is_crouching=false
var can_slide=true
var can_do_the_action=true
var is_wall_sliding=false
var can_jump=true
var grabbed=false
var got_hit=false
var can_be_target=true
var not_dead=true
var is_hooking=false
var grab_right=false
var grab_left=false
var chain_velocity := Vector2(0,0)
onready var cam=$Camera2D
onready var attack_hitbox =$Position2D/Att_hitbox
onready var ground_damage=$Ground_slam_hitbox
var player_stats=PlayerStats

func crawl():
	if Input.is_action_pressed("Crouch") and is_sliding==false and is_attackig==false and is_casting==false and is_on_floor():
		$Check_above.enabled=true
		$Colli1.disabled=true
		$Colli2.disabled=false
		is_crouching=true
	elif Input.is_action_just_released("Crouch") and is_sliding==false and is_attackig==false and is_casting==false and is_on_floor():
		if  not check_above():
			$Colli1.disabled=false
			$Colli2.disabled=true
			is_crouching=false
			$Check_above.enabled=false

func check():
	if $Check_above.enabled==false or !$Check_above.is_colliding() and !Input.is_action_pressed("Crouch") :
		is_crouching=false

func hook():
	if Input.is_action_just_pressed("Hook"):
		$Position2D/Chain.realease=false
		is_hooking=true
		motion.x=1
		motion.y=0
		if $Sprite.flip_h==false:
			$AnimationPlayer.play("Hooking")
			$Position2D/Chain.shoot(Vector2(1,0))
		elif $Sprite.flip_h==true:
			$AnimationPlayer.play("Hooking")
			$Position2D/Chain.shoot(Vector2(-1,0))



func hooked():
	if $Position2D/Chain.realease==true:
		is_hooking=false
		$Colli1.disabled=false
		$Colli2.disabled=true
		$Position2D/Chain.release()
	if $Position2D/Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Position2D/Chain.tip).normalized() * CHAIN_PULL
		$Colli1.disabled=true
		$Colli2.disabled=false
		if motion.x==0:
			is_hooking=false
			$Position2D/Chain.release()
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	motion.x += chain_velocity.x


func get_input_for_moving():
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right") and is_on_floor() and is_casting==false and is_hooking==false:
		$AnimationPlayer.play("Player Idle")
		motion.x = 0
		
	if Input.is_action_pressed("ui_left") and is_crouching==false and !Input.is_action_pressed("ui_right"):
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false:
			motion.x = max(motion.x-speed,-max_speed)
			if grabbed==false:
				$Sprite.flip_h=true
				if sign($Position2D.position.x)==1:
					$Position2D.position.x*=-1
			if (is_on_floor() or(is_on_floor() and next_to_wall())):
				if check_above():
					$AnimationPlayer.play("Crouch")
					is_crouching=true
				else:
					$AnimationPlayer.play("Player Running")

					$Colli1.disabled=false
					$Colli2.disabled=true
				
	elif Input.is_action_pressed("ui_right") and is_crouching==false and !Input.is_action_pressed("ui_left"):
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false:
			motion.x = min(motion.x+speed,max_speed)
			if grabbed==false:
				$Sprite.flip_h=false
				if sign($Position2D.position.x)==-1:
					$Position2D.position.x*=-1
			if (is_on_floor() or(is_on_floor() and next_to_wall())):
				if check_above():
					$AnimationPlayer.play("Crouch")
					is_crouching=true
				else:
					$AnimationPlayer.play("Player Running")
					$Colli1.disabled=false
					$Colli2.disabled=true
	elif Input.is_action_pressed("ui_right") and is_crouching==true:
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false:
			motion.x = 100
			$Sprite.flip_h=false
			if sign($Position2D.position.x)==-1:
				$Position2D.position.x*=-1
			if (is_on_floor() or(is_on_floor() and next_to_wall())):
				if check_above():
					$AnimationPlayer.play("Crouch")
					motion.x=100
				else:
					$AnimationPlayer.play("Crouch")

	elif Input.is_action_pressed("ui_left") and is_crouching==true:
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false:
			motion.x =-100
			$Sprite.flip_h=true
			if sign($Position2D.position.x)==1:
				$Position2D.position.x*=-1
			if (is_on_floor() or(is_on_floor() and next_to_wall())):
				if check_above():
					$AnimationPlayer.play("Crouch")
					motion.x=-100
				else:
					$AnimationPlayer.play("Crouch")

	else:
		if is_casting==false and is_sliding==false and is_attackig==false  and is_air_att==false and  is_hooking==false:
			motion.x = lerp(motion.x,0,0.2)
			if is_on_floor():
				if check_above() or Input.is_action_pressed("Crouch"):
					$AnimationPlayer.play("Crouch")
				else:
					$AnimationPlayer.play("Player Idle")
					$Colli1.disabled=false
					$Colli2.disabled=true
	if motion.x>0 or motion.x<0:
		is_running=true
	else:
		is_running=false




func gravity_apply():
	if is_air_att==false and is_hooking==false :
		motion.y += gravity

func cornor():
	if $Grab1.is_colliding()==false and next_to_right_wall()==true and is_crouching==false and is_sliding==false:
		grab_right=true
		grab_left=false
		grabbed=true
		motion.x=0
		motion.y=0
	elif $Grab2.is_colliding()==false and next_to_left_wall()==true  and is_crouching==false and is_sliding==false:
		grab_left=true
		grab_right=false
		grabbed=true
		motion.x=0
		motion.y=0
	else:
		grabbed=false


func is_grabed():
	if grabbed==true:
		is_casting=false
		if grab_right==true and $Sprite.flip_h==false:
			$Sprite.flip_h=false
			$AnimationPlayer.play("Grab")
		elif grab_right==true and $Sprite.flip_h==true:
			$Sprite.flip_h=false
			$AnimationPlayer.play("Grab")
		elif grab_left==true and $Sprite.flip_h==true:
			$Sprite.flip_h=true
			$AnimationPlayer.play("Grab")
		elif grab_left==true and $Sprite.flip_h==false:
			$Sprite.flip_h=true
			$AnimationPlayer.play("Grab")
		if Input.is_action_just_pressed("Crouch"):
			grabbed=false
			if $Sprite.flip_h==false:
				motion.x=-550
			else:
				motion.x=550
			$AnimationPlayer.play("Player Jumping")
		elif Input.is_action_just_pressed("ui_up"):
			grabbed=false
			motion.y=-600
			$AnimationPlayer.play("Player Jumping")




func get_input_for_jumping():
	if is_on_floor() or next_to_wall() and is_crouching==false and can_jump==true:
		first_jump=true
		jumps_left=1
		double_jump=false
		if Input.is_action_just_pressed("ui_up")&& is_casting==false and is_sliding==false and is_crouching==false and is_attackig==false and is_air_att==false:
			is_jumping=true
			motion.x = 0
			double_jump=true
			$AnimationPlayer.play("Player Jumping")
			motion.y =-jump_force
			if is_on_floor():
				var dust=Dust_jump.instance()
				get_parent().add_child(dust)
				dust.playing=true
				dust.position=$Bounce.global_position+Vector2(0,-27)
			if not is_on_floor() and next_to_right_wall() and grabbed==false:
				motion.x-=600
				can_jump=false
				yield(get_tree().create_timer(0.4), "timeout")
				can_jump=true
			elif not is_on_floor() and next_to_left_wall() and grabbed==false:
				motion.x+=600
				can_jump=false
				yield(get_tree().create_timer(0.4), "timeout")
				can_jump=true
	else:
		var double_dust=Double_jump_dust.instance()
		if Input.is_action_just_pressed("ui_up")&& is_casting==false && double_jump==true and is_attackig==false and can_jump==true and is_air_att==false:
			first_jump=false
			$AnimationPlayer.play("Double Jump")
			get_parent().add_child(double_dust)
			double_dust.playing=true
			double_dust.position=$Bounce.global_position+Vector2(0,-27)
			double_jump=false
			jumps_left-=1
			motion.y =-jump_force
		elif Input.is_action_just_pressed("ui_up")&& is_casting==false && jumps_left==1 and is_attackig==false and can_jump==true and is_air_att==false:
			first_jump=false
			$AnimationPlayer.play("Double Jump")
			get_parent().add_child(double_dust)
			double_dust.playing=true
			double_dust.position=$Bounce.global_position+Vector2(0,-27)
			motion.y =-jump_force
			jumps_left-=1
	if motion.y>550 and not next_to_wall() and not is_casting and not is_attackig and is_air_att==false:
		$AnimationPlayer.play("Player Falling")
	if friction==true:
			motion.x = lerp(motion.x,0,0.05)


func get_input_for_attacking():
	var fireball_cast=Fireball.instance()
	if sign($Position2D.position.x)==1:
		fireball_cast.knockback_vector=300
		fireball_cast.get_fireball_direction(1)
	else:
		fireball_cast.get_fireball_direction(-1)
		fireball_cast.knockback_vector=-300
	get_parent().add_child(fireball_cast)
	fireball_cast.position=$Position2D.global_position



func attacking_at_least():
	if is_on_floor() or grabbed==true:
		air_att_points=3
		if Input.is_action_just_pressed("Attack") and attack_points==3 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attackt1")
		elif Input.is_action_just_pressed("Attack") and attack_points==2 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attack2")
		elif Input.is_action_just_pressed("Attack") and attack_points==1 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attack3")
	elif not is_on_floor() and not next_to_wall():
		if Input.is_action_just_pressed("Attack") and air_att_points==3 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false :
			is_air_att=true
			motion.x=0
			motion.y=0
			$AnimationPlayer.play("air1")
		elif Input.is_action_just_pressed("Attack") and air_att_points==2 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false:
			is_air_att=true
			motion.x=0
			motion.y=0
			$AnimationPlayer.play("air2")
		elif Input.is_action_just_pressed("Attack") and air_att_points==1 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false:
			$Final.enabled=true
			$Final2.enabled=true
			$Final3.enabled=true
			$RightWall1.enabled=false
			$RightWall2.enabled=false
			$LeftWall1.enabled=false
			$LeftWall2.enabled=false
			is_air_att=true
			motion.x=0
			motion.y=0
			$AnimationPlayer.play("air3")
			

func landing():
	if $Sprite.flip_h==true:
		if $Final.is_colliding() or $Final2.is_colliding() or $Final3.is_colliding():
			if is_on_floor():
				$RightWall1.enabled=true
				$RightWall2.enabled=true
				$LeftWall1.enabled=true
				$LeftWall2.enabled=true
				$Final.enabled=false
				$Final2.enabled=false
				$Final3.enabled=false
				$AnimationPlayer.play("Ground_slam")
	elif $Sprite.flip_h==false:
		if $Final.is_colliding() or $Final3.is_colliding() or  $Final2.is_colliding() :
			if is_on_floor():
				$RightWall1.enabled=true
				$RightWall2.enabled=true
				$LeftWall1.enabled=true
				$LeftWall2.enabled=true
				$Final.enabled=false
				$Final2.enabled=false
				$Final3.enabled=false
				$AnimationPlayer.play("Ground_slam")

func flip():
	if $Sprite.flip_h==true:
		if sign($Position2D.position.x)==1:
					$Position2D.position.x*=-1
	elif $Sprite.flip_h==false:
			if sign($Position2D.position.x)==-1:
				$Position2D.position.x*=-1








func cast():
	if Input.is_action_just_pressed("Cast Spell")  and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_attackig==false and is_air_att==false:
		if can_cast==true:
			$Cast_reset.start()
			is_casting=true
			motion.x=0
			$AnimationPlayer.play("Player Casting")



func next_to_wall():
	return next_to_right_wall() or next_to_left_wall()
func next_to_right_wall():
	return $RightWall1.is_colliding() and $RightWall2.is_colliding()
func next_to_left_wall():
	return $LeftWall1.is_colliding() and $LeftWall2.is_colliding()

func wall_sliding():
	if next_to_right_wall() and !is_on_floor() and motion.y>-200 and $Grab1.is_colliding():
		is_wall_sliding=true
		$Sprite.flip_h=false
		$AnimationPlayer.play("New Anim")
		if Input.is_action_pressed("ui_left"):
			$AnimationPlayer.play("Player Jumping")
	elif next_to_left_wall() and !is_on_floor() and motion.y>-200 and $Grab2.is_colliding():
		is_wall_sliding=true
		$Sprite.flip_h=true
		$AnimationPlayer.play("New Anim")
		if Input.is_action_pressed("ui_right"):
			$AnimationPlayer.play("Player Jumping")
	else:
		is_wall_sliding=false


func crouch_slide():
	if is_on_floor() and is_crouching==false and can_slide==true:
		if Input.is_action_just_pressed("Crouch") and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
			$Slide_reset.start()
			can_slide=false
			is_sliding=true
			$Check_above.enabled=true
			$AnimationPlayer.play("Slide")
			if Input.is_action_pressed("ui_right"):
				motion.x=max_speed+200
			else:
				motion.x=-(max_speed+200)
			$Colli1.disabled=true
			$Colli2.disabled=false
			yield(get_tree().create_timer(0.6), "timeout")
			if check_above():
				$AnimationPlayer.play("Crouch")
				
			else:
				
				$Colli1.disabled=false
				$Colli2.disabled=true
				$Check_above.enabled=false
			is_sliding=false




func check_above():
	return $Check_above.is_colliding()

func update_Hurtbox():
	if is_sliding==true or is_crouching==true:
		hbox_update()
	else:
		hbox_reset()

func hbox_update():
	$Hurtbox.position.x=0
	$Hurtbox.position.y=38.214
	$Hurtbox.scale.x=2
	$Hurtbox.scale.y=2.5
	
func hbox_reset():
	$Hurtbox.position.x=0
	$Hurtbox.position.y=-7.283
	$Hurtbox.scale.x=2.86
	$Hurtbox.scale.y=6.307

func enemy_knock_direction():
	ground_damage.knockback_vector=-500
	ground_damage.player_position=position.x
	if $Sprite.flip_h==false:
		attack_hitbox.knockback_vector=400
	elif $Sprite.flip_h==true:
		attack_hitbox.knockback_vector=-400

func player_got_hurt(delta):
	if player_stats.health>0 :
		motion=motion.move_toward(Vector2.ZERO,100*delta)
		motion= move_and_slide(motion,UP)
	
func player_die():
	$AnimationPlayer.play("Player Die")
	can_be_detected=false
	can_be_target=false
	not_dead=false
	player_stats.disconnect("no_health",self,"player_die")
	if is_on_floor():
		motion.x=0
		set_physics_process(false)

func check2():
	if !get_input_for_jumping() and motion.y<0:
		$AnimationPlayer.play("Player Jumping")


func _physics_process(delta):
	if got_hit==false:
		hooked()
		hook()
		gravity_apply()
		get_input_for_moving()
		get_input_for_jumping()
		cast()
		attacking_at_least()
		crouch_slide()
		crawl()
		check()
		landing()
		cornor()
		is_grabed()
		flip()
		wall_sliding()
		enemy_knock_direction()
		update_Hurtbox()
		motion=move_and_slide(motion,UP,true)
	elif got_hit==true:
		gravity_apply()
		player_got_hurt(delta)
		motion=move_and_slide(motion,UP,true)

func _on_AnimationPlayer_animation_finished(cast):
	if cast=="Player Casting":
		get_input_for_attacking()
		is_casting=false
	if cast=="Attackt1" or cast=="Attack2" or cast=="Attack3":
		is_attackig=false
		attack_points-=1
	if cast=="air1" or cast=="air2":
		is_air_att=false
		air_att_points-=1
	if cast=="Ground_slam":
		is_air_att=false
		air_att_points-=1
	if cast=="Hurt":
		got_hit=false




func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name=="Hurt":
		player_stats.health-=1
	if anim_name=="Player Casting":
		can_cast=false
	if anim_name=="New Anim":
		motion.y=50
		motion.y=lerp(motion.y,500,0.3)
	if anim_name=="air3":
		motion.y+=800
	if anim_name=="Ground_slam":
		$Position2D/Att_hitbox/CollisionShape2D.disabled=true


func _on_Timer_timeout():
	attack_points=3



func _on_Cast_reset_timeout():
	can_cast=true


func _on_Slide_reset_timeout():
	can_slide=true





func _on_Hurtbox_area_entered(area):
	if can_be_target==true:
		is_casting=false
		is_air_att=false
		is_attackig=false
		is_sliding=false
		is_wall_sliding=false
		can_be_target=false
		$Hurt_reset.start()
		got_hit=true
		$Camera2D/ScreenShake.screen_shake(0.5,5,100)
		$AnimationPlayer.play("Hurt")
		if area.name=="kot":
			if area.enemy_position>position.x:
				motion.x=area.knockback_vector
			elif area.enemy_position<position.x:
				motion.x=-area.knockback_vector
		else:
			motion.x=area.knockback_vector
		print("Hurt")


func _on_Hurt_reset_timeout():
	if not_dead==true:
		can_be_target=true


func _ready():
	player_stats.connect("no_health",self,"player_die")
	set_physics_process(false)

