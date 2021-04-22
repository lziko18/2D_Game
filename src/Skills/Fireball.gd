extends Area2D

const HitEffect = preload("res://Effects/Fire_effect.tscn")
const fireball_speed = 600
var fireball_motion = Vector2()
var direction= 1 
var dir2=1
var knockback_vector=0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func get_fireball_direction(dir):
	direction=dir
	dir2=dir
	if dir==-1:
		$Fireball_animation.flip_h=true

func _process(delta):
	fireball_motion.x = fireball_speed * delta* direction
	translate(fireball_motion)
	$Fireball_animation.play("Fireball_shooting")


func _on_Fireball_visibility_screen_exited():
	queue_free()


func _on_Fireball_body_entered(_body):
	var effect = HitEffect.instance()
	if dir2==-1:
		effect.flip_h=true
	elif dir2==1:
		effect.flip_h=false
	get_tree().get_root().add_child(effect)
	effect.playing=true
	if dir2==-1:
		effect.global_position=global_position +Vector2(15,-10)
	elif dir2==1:
		effect.global_position=global_position +Vector2(-15,-10)
	queue_free()

func _on_Fireball_area_entered(_area):
	var effect = HitEffect.instance()
	if dir2==-1:
		effect.flip_h=true
	elif dir2==1:
		effect.flip_h=false
	get_tree().get_root().add_child(effect)
	effect.playing=true
	if dir2==-1:
		effect.global_position=global_position +Vector2(15,-10)
	elif dir2==1:
		effect.global_position=global_position +Vector2(-15,-10)
	queue_free()
