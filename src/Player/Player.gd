extends KinematicBody2D

# This script controls players movement
const Fireball = preload("res://Skills/Fireball.tscn")
const Dust_jump = preload("res://Effects/Dust.tscn")
const Double_jump_dust=preload("res://Effects/Double_jump_dust.tscn")
const DIALOG=preload("res://UI/Dialog.tscn")
const UP=Vector2(0,-1)
const CHAIN_PULL = 105
var can_be_detected=true
var motion=Vector2()

const speed=50
const max_speed=300
const jump_force=600
const gravity=30
const double_jump_force= 500

var jumps_left=0
var attack_points=3
var air_att_points=3
var can_hook=false
var double_jump=false
var friction=true
var is_casting=false
var is_running=null
var is_jumping=null
var first_jump=true
var can_cast=false
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
var last_floor_position = Vector2(0, 0)
var last_floor_ctr = 0
var speaking_to=""
var health_current : int
var health_max : int
var is_speaking=false
var can_speak=false
var world_name
var cnt=1
var wizard 
var bandit
var spirit_fire=false
var runes=false
var obelisk=false
var grappling=false

var player_stats
onready var cam=$Camera2D
onready var attack_hitbox =$Position2D/Att_hitbox
onready var ground_damage=$Ground_slam_hitbox

var save_data = null

func load_save(data):
	save_data = data

func reset_health():
	health_current = health_max
	update_health()

func take_damage(amount):
	health_current = health_current - amount
	if health_current<=0:
		player_die()
	update_health()
	
func heal(amount):
	health_current = health_current + amount
	if health_current > health_max:
		health_current = health_max
	update_health()
	$Example5/Particles2D2.emitting=true
	$Example5/Flare2.visible=true
	yield(get_tree().create_timer(0.5), "timeout")
	$Example5/Flare2.visible=false
	$Example5/Particles2D2.emitting=false


func add_health(amount):
	health_max = health_max + amount
	update_max_health()
	update_health()

func update_health():
	player_stats.set_hearts(health_current)
func update_max_health():
	player_stats.set_max_hearts(health_max)


func crawl():
	if Input.is_action_pressed("Crouch") and is_sliding==false and is_attackig==false and is_casting==false and is_on_floor() and is_air_att==false and is_speaking==false:
		$Check_above.enabled=true
		$Colli1.disabled=true
		$Colli2.disabled=false
		is_crouching=true
	elif Input.is_action_just_released("Crouch") and is_sliding==false and is_attackig==false and is_casting==false and is_on_floor() and is_speaking==false:
		if  not check_above():
			$Colli1.disabled=false
			$Colli2.disabled=true
			is_crouching=false
			$Check_above.enabled=false

func check():
	if $Check_above.enabled==false or !$Check_above.is_colliding() and !Input.is_action_pressed("Crouch") :
		is_crouching=false

func hook():
	if Input.is_action_just_pressed("Hook") and is_sliding==false and is_attackig==false and is_casting==false and is_air_att==false and is_crouching==false and is_wall_sliding==false and grabbed==false and is_speaking==false and can_hook==true:
		$Position2D/Chain.realease=false
		can_hook=false
		$Hook.start()
		is_hooking=true
		if $Sprite.flip_h==true:
			motion.x=1
		elif $Sprite.flip_h==false:
			motion.x=-1
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
		$Position2D/Chain.release()
	if $Position2D/Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Position2D/Chain.tip).normalized() * CHAIN_PULL
		if motion.x==0 or motion.y!=0:
			is_hooking=false
			$Position2D/Chain.release()
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	motion.x += chain_velocity.x


func get_input_for_moving():
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right") and is_on_floor() and is_casting==false and is_hooking==false and is_attackig==false and is_air_att==false and is_sliding==false and is_crouching==false and is_speaking==false:
		$AnimationPlayer.play("Player Idle")
		motion.x = 0
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right") and is_on_floor() and is_casting==false and is_hooking==false and is_attackig==false and is_air_att==false and is_sliding==false and is_crouching==true and is_speaking==false:
		$AnimationPlayer.play("Crouch")
		motion.x = 0
		
	if Input.is_action_pressed("ui_left") and is_crouching==false and !Input.is_action_pressed("ui_right"):
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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
	elif Input.is_action_pressed("ui_right") and is_crouching==true and !Input.is_action_pressed("ui_left"):
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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

	elif Input.is_action_pressed("ui_left") and is_crouching==true and  !Input.is_action_pressed("ui_right"):
		if is_casting==false and is_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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
		if is_casting==false and is_sliding==false and is_attackig==false  and is_air_att==false and  is_hooking==false and is_speaking==false:
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
	if $Grab1.is_colliding()==false and next_to_right_wall()==true and is_crouching==false and is_sliding==false and is_speaking==false:
		grab_right=true
		grab_left=false
		grabbed=true
		motion.x=0
		motion.y=0
	elif $Grab2.is_colliding()==false and next_to_left_wall()==true  and is_crouching==false and is_sliding==false and is_speaking==false:
		grab_left=true
		grab_right=false
		grabbed=true
		motion.x=0
		motion.y=0
	else:
		grabbed=false


func is_grabed():
	if grabbed==true :
		is_casting=false
		is_attackig=false
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
	if is_on_floor() or next_to_wall() and is_crouching==false and can_jump==true and is_hooking==false and is_speaking==false:
		first_jump=true
		jumps_left=1
		double_jump=false
		if Input.is_action_just_pressed("ui_up")&& is_casting==false and is_sliding==false and is_crouching==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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
		if Input.is_action_just_pressed("ui_up")&& is_casting==false && double_jump==true and is_attackig==false and can_jump==true and is_air_att==false  and is_hooking==false and is_speaking==false:
			first_jump=false
			$AnimationPlayer.play("Double Jump")
			get_parent().add_child(double_dust)
			double_dust.playing=true
			double_dust.position=$Bounce.global_position+Vector2(0,-27)
			double_jump=false
			jumps_left-=1
			motion.y =-jump_force
		elif Input.is_action_just_pressed("ui_up")&& is_casting==false && jumps_left==1 and is_attackig==false and can_jump==true and is_air_att==false  and is_hooking==false and is_speaking==false:
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

func speaking():
	if Input.is_action_just_pressed("Talk_Read") and is_on_floor() and is_sliding==false and is_attackig==false and  is_air_att==false  and is_casting==false and is_crouching==false and is_hooking==false and can_speak==true and cnt==1:
		cnt=0
		motion.x=0
		var dialog=DIALOG.instance()
		dialog.get_node("DialogBox").who=speaking_to
		if wizard==true:
			dialog.get_node("DialogBox").wizard=true
		elif bandit==true:
			dialog.get_node("DialogBox").bandit=true
		$AnimationPlayer.play("Player Idle")
		is_speaking=true
		$Camera2D/CanvasLayer.add_child(dialog)

func attacking_at_least():
	if is_on_floor() :
		air_att_points=3
		if Input.is_action_just_pressed("Attack") and attack_points==3 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false and is_hooking==false and is_speaking==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attackt1")
		elif Input.is_action_just_pressed("Attack") and attack_points==2 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false and is_hooking==false and is_speaking==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attack2")
		elif Input.is_action_just_pressed("Attack") and attack_points==1 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_air_att==false and is_hooking==false and is_speaking==false:
			$Attack_reset.start()
			is_attackig=true
			motion.x=0
			$AnimationPlayer.play("Attack3")
	elif not is_on_floor() and not next_to_wall():
		if Input.is_action_just_pressed("Attack") and air_att_points==3 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false and is_hooking==false and is_speaking==false:
			is_air_att=true
			motion.x=0
			motion.y=0
			$AnimationPlayer.play("air1")
		elif Input.is_action_just_pressed("Attack") and air_att_points==2 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false and is_hooking==false and is_speaking==false:
			is_air_att=true
			motion.x=0
			motion.y=0
			$AnimationPlayer.play("air2")
		elif Input.is_action_just_pressed("Attack") and air_att_points==1 and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_casting==false and is_attackig==false and is_hooking==false and is_speaking==false:
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
	if Input.is_action_just_pressed("Cast Spell")  and is_sliding==false and is_crouching==false and is_wall_sliding==false and is_attackig==false and is_air_att==false and is_hooking==false and is_speaking==false:
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
	if next_to_right_wall() and !is_on_floor() and motion.y>-200 and $Grab1.is_colliding() and is_casting==false and is_attackig==false and is_hooking==false and is_speaking==false:
		is_wall_sliding=true
		$Sprite.flip_h=false
		$AnimationPlayer.play("New Anim")
		if Input.is_action_pressed("ui_left"):
			$AnimationPlayer.play("Player Jumping")
	elif next_to_left_wall() and !is_on_floor() and motion.y>-200 and $Grab2.is_colliding()and is_casting==false and is_attackig==false and is_hooking==false and is_speaking==false:
		is_wall_sliding=true
		$Sprite.flip_h=true
		$AnimationPlayer.play("New Anim")
		if Input.is_action_pressed("ui_right"):
			$AnimationPlayer.play("Player Jumping")
	else:
		is_wall_sliding=false


func crouch_slide():
	if is_on_floor() and is_crouching==false and can_slide==true and is_attackig==false and is_casting==false and is_wall_sliding==false and is_air_att==false and is_hooking==false and is_speaking==false:
		if Input.is_action_just_pressed("Crouch") and ((Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"))or (Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"))):
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
	got_hit=true
	can_be_detected=false
	can_be_target=false
	not_dead=false
	
	
	
func finish_him():
	if is_on_floor():
		$AnimationPlayer.play("Player Die")
		motion.x=0
		set_physics_process(false)
	elif !is_on_floor():
		$AnimationPlayer.play("hurt_wait")

		

func check2():
	if !get_input_for_jumping() and motion.y<0:
		$AnimationPlayer.play("Player Jumping")


func _physics_process(_delta):
	update_floor_position()
	if got_hit==false:
		flip()
		gravity_apply()
		cast()
		attacking_at_least()
		crouch_slide()
		crawl()
		check()
		landing()
		enemy_knock_direction()
		update_Hurtbox()
		get_input_for_moving()
		get_input_for_jumping()
		wall_sliding()
		cornor()
		is_grabed()
		hooked()
		hook()
		speaking()
		motion=move_and_slide(motion,UP,true)
	elif got_hit==true:
		gravity_apply()
		if not_dead==false:
			finish_him()
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
		$Bounce/CollisionShape2D.disabled=false
		is_air_att=false
		air_att_points-=1
	if cast=="Hurt":
		got_hit=false
	if cast == "Player Die":
		get_tree().get_root().get_node("/root/Transition").get_node("Transition/Video").play("transition")
		yield(get_tree().create_timer(1), "timeout")
		var game = get_tree().get_root().get_node("Game")
		game.load_game("Checkpoint")
		update_max_health()
		update_health()





func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name!="air1" or anim_name!="air2" or anim_name!="Attack1" or anim_name!="Attack2" or anim_name!="Attack3":
		$Position2D/Att_hitbox/CollisionShape2D.disabled=true
	if anim_name=="Hurt":
		$Bounce/CollisionShape2D.disabled=false
		$Position2D/Att_hitbox/CollisionShape2D.disabled=true
		if not_dead==true:
			take_damage(1)
	if anim_name=="Player Casting":
		can_cast=false
	if anim_name=="New Anim":
		motion.y=50
		motion.y=lerp(motion.y,500,0.3)
	if anim_name=="air3":
		motion.y+=800
	if anim_name=="Ground_slam":
		$Position2D/Att_hitbox/CollisionShape2D.disabled=true
	if anim_name=="air3":
			$Bounce/CollisionShape2D.disabled=true



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
		motion.x=area.knockback_vector
		print("Hurt")


func _on_Hurt_reset_timeout():
	if not_dead==true:
		can_be_target=true

func get_save_data():
	var data = {
		"position": {
			"x": global_position.x,
			"y": global_position.y
		},
		"health": {
			"current": health_current,
			"max": health_max
		},
		"world_name": world_name,
		"jumps_left": jumps_left,
		"attack_points": attack_points,
		"air_att_points": air_att_points,
		"can_hook": can_hook,
		"double_jump": double_jump,
		"friction": friction,
		"is_casting": is_casting,
		"is_running": is_running,
		"is_jumping": is_jumping,
		"first_jump": first_jump,
		"can_cast": can_cast,
		"is_sliding": is_sliding,
		"is_attackig": is_attackig,
		"is_air_att": is_air_att,
		"is_crouching": is_crouching,
		"can_slide": can_slide,
		"can_do_the_action": can_do_the_action,
		"is_wall_sliding": is_wall_sliding,
		"can_jump": can_jump,
		"grabbed": grabbed,
		"got_hit": got_hit,
		"can_be_target": can_be_target,
		"not_dead": not_dead,
		"is_hooking": is_hooking,
		"grab_right": grab_right,
		"grab_left": grab_left,
		"chain_velocity" : {
			"x": chain_velocity.x,
			"y": chain_velocity.y
		},
		"last_floor_position": {
			"x": last_floor_position.x,
			"y": last_floor_position.y
		},
		"last_floor_ctr": last_floor_ctr,
		"speaking_to": speaking_to,
		"health_current" : health_current,
		"health_max" : health_max,
		"is_speaking": is_speaking,
		"can_speak": can_speak,
		"cnt": cnt,
		"wizard": wizard,
		"bandit": bandit,
		"spirit_fire": spirit_fire,
		"runes": runes,
		"obelisk": obelisk,
		"grappling": grappling,
		"animation": {
			"name": $AnimationPlayer.current_animation,
			"position": $AnimationPlayer.current_animation_position
		}
	}
	return data

func set_from_save_data(data):
	global_position.x = data.position.x
	global_position.y = data.position.y
	health_max = data.health["max"]
	health_current = data.health.current
	world_name = data.world_name
	jumps_left=data.jumps_left
	#attack_points=data.attack_points
	#air_att_points=data.air_att_points
	can_hook=data.can_hook
	double_jump=data.double_jump
	friction=data.friction
	#is_casting=data.is_casting
	#is_running=data.is_running
	#is_jumping=data.is_jumping
	first_jump=data.first_jump
	can_cast=data.can_cast
	#is_sliding=data.is_sliding
	#is_attackig=data.is_attackig
	#is_air_att=data.is_air_att
	#is_crouching=data.is_crouching
	can_slide=data.can_slide
	can_do_the_action=data.can_do_the_action
	#is_wall_sliding=data.is_wall_sliding
	can_jump=data.can_jump
	grabbed=data.grabbed
	got_hit=data.got_hit
	can_be_target=data.can_be_target
	not_dead=data.not_dead
	#is_hooking=data.is_hooking
	grab_right=data.grab_right
	grab_left=data.grab_left
	chain_velocity = Vector2(data.chain_velocity.x, data.chain_velocity.y)
	last_floor_position = Vector2(data.last_floor_position.x, data.last_floor_position.y)
	last_floor_ctr = int(data.last_floor_ctr)
	#speaking_to=data.speaking_to
	#is_speaking=data.is_speaking
	#can_speak=data.can_speak
	world_name=data.world_name
	cnt=data.cnt
	wizard = data.wizard
	bandit = data.bandit
	spirit_fire = data.spirit_fire
	runes=data.runes
	obelisk=data.obelisk
	grappling=data.grappling
	$AnimationPlayer.play(data.animation.name)
	$AnimationPlayer.seek(data.animation.position)

func _ready():
	#player_stat.connect("no_health",self,"player_die")
	player_stats=get_node("Camera2D/CanvasLayer/Prova")
	#set_physics_process(false)

	if save_data == null:
		health_max = 8
		update_max_health()
		health_current = 8
		update_health()
	else:
		set_from_save_data(save_data)
		save_data = null
		update_max_health()
		update_health()


func update_floor_position():
	last_floor_ctr += 1
	if last_floor_ctr % 5 == 0:
		last_floor_ctr -= 5
		if is_on_floor() and $check_for_end1.is_colliding()==true and $check_for_end2.is_colliding()==true:
			last_floor_position.x = global_position.x
			last_floor_position.y = global_position.y


func _on_Hook_timeout():
	can_hook=true
