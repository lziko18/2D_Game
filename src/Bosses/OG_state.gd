extends StateMachine
var time=0.5
func _ready():
	add_state('idle') #0
	add_state('walk') #1
	add_state('att1') #2
	add_state('att2') #3
	add_state('spit') #4
	add_state('die') #5
	add_state('jump') #6
	

	call_deferred("set_state",states.walk)
func _input(event):
	if[states.idle,states.walk].has(state):
		if event.is_action_pressed("ui_down"):
			parent.attack3=true
			set_state(4)
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
		states.walk:
			parent.get_node("AnimationPlayer").play("Walk")
		states.att1:
			parent.get_node("AnimationPlayer").play("Att1")
		states.att2:
			parent.get_node("AnimationPlayer").play("Att2")
		states.die:
			parent.get_node("AnimationPlayer").play("Die")
		states.spit:
			parent.get_node("AnimationPlayer").play("Spit")
		states.jump:
			parent.get_node("AnimationPlayer").play("Jump")


func _exit_state(old_state,new_state):
	match old_state:
		states.idle:
			pass
