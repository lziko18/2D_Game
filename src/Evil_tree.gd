extends Sprite
export  var direction=1
const Dust=preload("res://Spikes.tscn")
var can_attack=false
var state
var seen
var where= Vector2()
var cnt=1
var player
var health=4
enum{
	Attack,
	Idle,
	Die,
}
var can_flip=true

# Called when the node enters the scene tree for the first time.
func _ready():
	state=Idle
	player = get_tree().get_root().get_node("World/Player")

func _physics_process(_delta):
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
		Die:
			$Hurtbox/CollisionShape2D2.disabled=true
			$Area2D2/CollisionShape2D2.disabled=true
			$AnimationPlayer.play("Die")


func flip():
	var dir=get_tree().get_root().get_node("World").get_node("Player").global_position.x
	var our=global_position.x
	if can_flip:
		if our > dir:
			self.flip_h=true
			$Hurtbox.position.x=-6.1
			$Area2D2.position.x=-6.1
		elif our < dir:
			self.flip_h=false
			$Hurtbox.position.x=6.1
			$Area2D2.position.x=6.1


func attack_state():
	$AnimationPlayer.play("Attack")

func can_flip_true():
	can_flip=true

func can_flip_false():
	can_flip=false

func spawn():
	var spikes=Dust.instance()
	spikes.global_position=where
	get_parent().add_child(spikes)

func _on_Area2D_body_entered(body):
	if body.name=="Player":
		seen=true
		

func _on_Area2D_body_exited(body):
	if body.name=="Player":
		seen=false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="Attack":
		if seen==true and player.is_on_floor():
			state=Attack
		else:
			state=Idle
	if anim_name=="Die":
		queue_free()


func _on_AnimationPlayer_animation_started(_anim_name):
	pass


func _on_Hurtbox_area_entered(area):
	health=health-1
	if health<=0:
		state=Die


func _on_Area2D2_body_entered(body):
	if body.name=="Player":
		body.take
