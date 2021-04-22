extends Node2D

var can_attack=true
export(int) var face=1
onready var guardianhealth = $Lizard_stats



func _ready():

	$Sprite/AnimationPlayer.play("Idle")
	checkface()


func checkface():
	if face!=1:
		$Sprite.scale.x=-1
		$Sprite.position.x=46.375


func _on_AnimationPlayer_animation_finished(name):
	if name=="Hit_da_boy":
		$Sprite/Position2D/Area2D.scale.y=1
		$Sprite/Position2D/Area2D.rotation_degrees=0
		$Sprite/AnimationPlayer.play("Idle")
		$Sprite/Position2D/Player_detect/CollisionShape2D.disabled=true
		$Sprite/Position2D/Player_detect/CollisionShape2D.disabled=false
		can_attack=true
	if name=="Guardian_death":
		queue_free()



func _on_AnimationPlayer_animation_started(name):
	if name=="Hit_da_boy":
		can_attack=false
		$Sprite/Position2D/Player_detect/CollisionShape2D.set_deferred("disabled",true)
	if name=="Guardian_death":
		can_attack=false



func _on_Player_detect_body_entered(body):
	if body.can_be_detected==true:
		if can_attack==true:
			$Sprite/AnimationPlayer.play("Hit_da_boy")



func _on_Hurtbox_area_entered(_area):
	guardianhealth.health-=1
	if guardianhealth.health<=0:
		$Sprite/AnimationPlayer.play("Guardian_death")
		$Sprite/Hurtbox.queue_free()
		$Sprite/Position2D/Area2D.queue_free()
