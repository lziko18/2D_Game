extends Sprite
export  var direction=1
const Dust=preload("res://Spikes.tscn")
var can_attack=false
var state
var seen
var where= Vector2()
var cnt=1
var player
enum{
	Attack,
	Idle,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	state=Idle
	player = get_tree().get_root().get_node("World/Player")

func _physics_process(delta):
	if player.is_on_floor() and get_tree().get_root().get_node("World/Player/check_for_end3").is_colliding() and get_tree().get_root().get_node("World/Player/check_for_end4").is_colliding():
		where.x=player.global_position.x
		where.y=player.global_position.y-12
	match state:
		Idle:
			flip()
			$AnimationPlayer.play("Idle")
			if seen==true and player.is_on_floor():
				state=Attack
		Attack:
			flip()
			attack_state()


func flip():
	var dir=get_tree().get_root().get_node("World").get_node("Player").global_position.x
	var our=global_position.x
	if our > dir:
		self.flip_h=true
	elif our < dir:
		self.flip_h=false


func attack_state():
	$AnimationPlayer.play("Attack")



func spawn():
	var spikes=Dust.instance()
	spikes.global_position=where
	get_parent().add_child(spikes)

func _on_Area2D_body_entered(body):
	if body.name=="Player":
		seen=true
		

func _on_Area2D_body_exited(body):
	seen=false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="Attack":
		if seen==true and player.is_on_floor():
			state=Attack
		else:
			state=Idle


func _on_AnimationPlayer_animation_started(anim_name):
	pass # Replace with function body.
