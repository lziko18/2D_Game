extends KinematicBody2D
export  var dir=1
var slime
var player
var rng = RandomNumberGenerator.new()
var num
enum{
	Happy,
	Idle
}
var state
# Called when the node enters the scene tree for the first time.
func _ready():
	if dir==1:
		$Sprite.flip_h=true
	else:
		$Sprite.flip_h=false
	state=Idle

func _physics_process(delta):
	slime=global_position.x
	player=get_parent().get_node("Player").global_position.x
	if  abs(slime - player)<200:
		if slime > player:
			$Sprite.flip_h=false
		elif slime < player:
			$Sprite.flip_h=true
			
	match state:
		Idle:
			$AnimationPlayer.play("idle")
			if  abs(slime - player)<100:
				rng.randomize()
				num=rng.randi()%10+1
				if int(num)<=5:
					state=Happy
				else:
					yield(get_tree().create_timer(0.5), "timeout")
					state=Happy
		Happy:
			$AnimationPlayer.play("happy")
			if  abs(slime - player)>=100:
				yield(get_tree().create_timer(0.8), "timeout")
				state=Idle





