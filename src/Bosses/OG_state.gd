extends StateMachine
var time=0.5
func _ready():
	add_state('idle') #0
	add_state('walk') #1
	add_state('att1') #2
	add_state('att2') #3
	add_state('spit') #4
	add_state('die') #5
	add_state('fake_idle') #6
	

	call_deferred("set_state",states.fake_idle)
func _input(event):
	#if[states.idle,states.walk].has(state):
		#if event.is_action_pressed("ui_down"):
			#parent.attack3=true
			#set_state(4)
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
	parent.player_knock_back()
	if state!=states.fake_idle :
		parent.get_node("Hurtbox/CollisionShape2D2").disabled=false
	if parent.is_dead==true and parent.is_on_floor()==true:
		set_state(5)
		parent.set_collision_mask_bit(1,false)
	if state==states.idle :
		parent.change_dir()
	if state==states.walk:
		parent.walk()
		parent.change_dir()



func _get_transition(delta):
	match state:
		states.idle:
			if parent.motion.x !=0 :
				return states.walk
			elif parent.attack==true:
				return states.att1
		states.walk:
			if parent.attack==true:
				return states.att1
	return null
func _enter_state(new_state,old_state):
	match new_state:
		states.idle:
			parent.get_node("AnimationPlayer").play("Idle")
			yield(get_tree().create_timer(1), "timeout")
			if parent.is_dead==false:
				parent.can_choose=true
				parent.ch_state1()

		states.walk:
			parent.get_node("AnimationPlayer").play("Walk")
			yield(get_tree().create_timer(0.5), "timeout")
			if parent.is_dead==false:
				parent.can_choose=true
				parent.ch_state1()
		states.att1:
			parent.get_node("AnimationPlayer").play("Att1")
			parent.can_choose=false
		states.att2:
			parent.get_node("AnimationPlayer").play("Att2")
			parent.can_choose=false
		states.die:
			parent.get_node("AnimationPlayer").play("Die")
			parent.can_choose=false
			parent.motion.x=0
		states.spit:
			parent.get_node("AnimationPlayer").play("Spit")
			parent.can_choose=false
		states.fake_idle:
			parent.get_node("AnimationPlayer").play("Idle")
			parent.can_choose=false


func _exit_state(old_state,new_state):
	match old_state:
		states.idle:
			parent.can_choose=false
		states.walk:
			parent.can_choose=false

