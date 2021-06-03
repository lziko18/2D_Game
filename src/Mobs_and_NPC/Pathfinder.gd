extends KinematicBody2D

export(int) var SPEED: int = 200
var velocity: Vector2 = Vector2.ZERO

var path: Array = []	# Contains destination positions
var levelNavigation: Navigation2D = null
var player = null
var player_spotted: bool = false
var stoppp
onready var line2d = $Line2D
onready var los = $LineOfSight
var health=2
enum{
	Wander,
	Attack,
	Hurt,
	Die,
	Hunt,
	Land,
}
var state
func _ready():
	state=Wander
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("LevelNavigation"):
		levelNavigation = tree.get_nodes_in_group("LevelNavigation")[0]
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

func _physics_process(delta):
	line2d.global_position = Vector2.ZERO
	if player:
		los.look_at(player.global_position)
		check_player_in_detection()
		move()
	match state:
		Attack:
			velocity.x=0
			velocity.y=0
			$AnimationPlayer.play("attack")
		Wander:
			velocity.x=0
			velocity.y=0
			$AnimationPlayer.play("idle")
			check_player_in_detection()
			if player_spotted:
				state=Hunt
		Hurt:
			$AnimationPlayer.play("New Anim")
		Die:
			$AnimationPlayer.play("die")
			velocity.x=0
			velocity.y+=20
			if $RayCast2D.is_colliding():
				state=Land
		Land:
			$AnimationPlayer.play("land")

		Hunt:
			flip()
			$AnimationPlayer.play("move")
			generate_path()
			navigate()
			if abs(player.global_position.x-global_position.x)>600 or abs(player.global_position.y-global_position.y)>600:
				player_spotted=false
				state=Wander
			elif abs(player.global_position.x-global_position.x)<30 and abs(player.global_position.y-global_position.y)<30 :
				player_spotted=false
				state=Attack
			

func check_player_in_detection() -> bool:
	var collider = los.get_collider()
	if collider and collider.is_in_group("Player"):
		player_spotted = true
		return true
	return false

func navigate():	# Define the next position to go to
	if path.size() > 0:
		velocity = global_position.direction_to(path[1]) * SPEED
		
		# If reached the destination, remove this point from path array
		if global_position == path[0]:
			path.pop_front()

func generate_path():
	if levelNavigation != null and player != null:
		path = levelNavigation.get_simple_path(global_position, player.global_position+Vector2(0,-30),false)
		line2d.points = path

func flip():
	if (player.global_position.x>global_position.x):
		$AnimationPlayer.play("move")
		$Sprite.flip_h=true
		$Area2D.position.x=13
		$Sprite.position.x=13
	elif player.global_position.x<global_position.x:
		$AnimationPlayer.play("move")
		$Sprite.flip_h=false
		$Area2D.position.x=-13
		$Sprite.position.x=-13


func move():
	velocity = move_and_slide(velocity)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="attack":
		state=Wander
	if anim_name=="New Anim":
		state=Wander
	if anim_name=="land":
		queue_free()


func _on_AnimationPlayer_animation_started(anim_name):
		if anim_name=="attack":
			yield(get_tree().create_timer(0.25), "timeout")
			if $Sprite.flip_h==true:
				velocity.x=400
			elif $Sprite.flip_h==false:
				velocity.x=-400
			yield(get_tree().create_timer(0.05), "timeout")
			velocity.x=0
			velocity.y=0





func _on_Hurtbox_area_entered(area):
	state=Hurt
	health=health-1
	if health==0:
		state=Die
	if area.name=="Att_hitbox":
		velocity.x=area.knockback_vector*0.5
	else:
		velocity.x=0 



