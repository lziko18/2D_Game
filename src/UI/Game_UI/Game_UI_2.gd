extends Camera2D


func change_left(from,to):
	$Tween.interpolate_property(self,"limit_left",from,to,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.start()
func change_right(from,to):
	$Tween.interpolate_property(self,"limit_right",from,to,1,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	$Tween.start()
