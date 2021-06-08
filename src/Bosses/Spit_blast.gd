extends AnimatedSprite

var dir

func _ready():
	if dir =="left":
		self.flip_h=true
	elif dir =="right":
		self.flip_h=false


func _on_Spit_blast_animation_finished():
	queue_free()
