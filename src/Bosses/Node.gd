extends StateMachine

func _ready():
	add_state('walk') #0
	add_state('dash') #1
	add_state('jump_up')#2
	add_state('jump_down')#3
	add_state('idle')#4
	add_state('jump_charge')#5
	add_state('spin')#6
	add_state('attack1')#7
	add_state('attack2')#8
	add_state('attack3')#9
	add_state('leap_up')#10
	add_state('leap_down')#12
	call_deferred("set_state",states.idle)
	
func _input(event):
	#if[states.idle,states.walk].has(state):
		#if event.is_action_pressed("ui_up"):
			#parent.jump_attack=true
			#set_state(5)
	#if[states.idle,states.walk].has(state):
		#	parent.spin_attack=true
			#set_state(6)
	#if[states.idle,states.walk].has(state):
		#if event.is_action_pressed("Go left"):
			#parent.dash=true
			#set_state(1)
	#if[states.idle,states.walk,states.dash].has(state):
		#if event.is_action_pressed("ui_down"):
		#	parent.attack=true
			#if parent.dash==false:
			#	set_state(8)
	#if[states.idle,states.walk,states.dash].has(state):
		#if event.is_action_pressed("Hook"):
		#	parent.leap=true
			#set_state(10)
			pass
	




func _state_logic(delta):
	parent.gravity()
	if state==states.idle or state==states.leap_up :
		parent.change_dir()
	if state==states.walk:
		parent.change_dir()
		parent.walk()


func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.motion.y<0:
					return states.jump_up
				elif parent.motion.y>0:
					return states.jump_down
			elif parent.motion.x !=0 :
				return states.walk
			elif parent.jump_attack==true:
				return states.jump_charge
			elif parent.attack==true:
				return states.attack1
		states.walk:
			if !parent.is_on_floor():
				if parent.motion.y<0:
					return states.jump_up
				elif parent.motion.y>0:
					return states.jump_down
			elif parent.jump_attack==true:
				return states.jump_charge
			elif parent.spin_attack==true:
				return states.spin
			elif parent.attack==true:
				return states.attack1
		states.jump_up:
			if parent.is_on_floor():
				return states.idle
			elif parent.motion.y>=0:
				return states.jump_down
		states.jump_down:
			if parent.motion.y<0:
				return states.jump_up
			if parent.motion.y==0:
				parent.motion.x=0
		states.spin:
			if parent.motion.y<0:
				return states.jump_up
			elif parent.motion.y>0:
				return states.jump_down
		states.dash:
			if parent.motion.y<0:
				return states.jump_up
			elif parent.motion.y>0:
				return states.jump_down
			elif parent.motion.x==0 and parent.dash==false:
				return states.idle
			elif parent.motion.x!=0 and parent.dash==false:
				return states.walk
	return null

func _enter_state(new_state,old_state):
	match new_state:
		states.idle:
			parent.motion.x=0
			parent.get_node("AnimationPlayer").play("boss_idle")
			parent.can_choose=true
			yield(get_tree().create_timer(0.5), "timeout")
			parent.choose_state()
		states.walk:
			parent.can_choose=true
			parent.get_node("AnimationPlayer").play("boss_walk");
			yield(get_tree().create_timer(0.5), "timeout")
			parent.choose_state2()
		states.jump_up:
			parent.get_node("AnimationPlayer").play("boss_jump_up")
			parent.can_choose=false
		states.jump_down:
			parent.get_node("AnimationPlayer").play("boss_jump_down")
			parent.can_choose=false
		states.jump_charge:
			parent.motion.x=0
			parent.get_node("AnimationPlayer").play("boss_jump_charge")
			parent.can_choose=false
		states.spin:
			parent.motion.x=0
			parent.get_node("AnimationPlayer").play("boss_spin_att")
			parent.can_choose=false
		states.attack1:
			parent.get_node("AnimationPlayer").play("boss_att_01")
			parent.can_choose=false
		states.attack2:
			parent.get_node("AnimationPlayer").play("boss_att_02")
			parent.can_choose=false
		states.attack3:
			parent.get_node("AnimationPlayer").play("boss_att_03")
			parent.can_choose=false
		states.dash:
			parent.get_node("AnimationPlayer").play("boss_dash")
			parent.can_choose=false
		states.leap_up:
			parent.get_node("AnimationPlayer").play("boss_leap_up")
			parent.can_choose=false
		states.leap_down:
			parent.get_node("AnimationPlayer").play("boss_leap_down")
			parent.can_choose=false

	
func _exit_state(old_state,new_state):
	match old_state:
		states.idle:
			parent.can_choose=false
		states.walk:
			parent.can_choose=false
		states.dash:
			parent.dash=false
			

