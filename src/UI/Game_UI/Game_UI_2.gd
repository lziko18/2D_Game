extends Camera2D


func change_left(from,to):
	$Tween.interpolate_property(self,"limit_left",from,to,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()
func change_right(from,to):
	$Tween.interpolate_property(self,"limit_right",from,to,0.1,Tween.TRANS_CUBIC,Tween.EASE_OUT)
	$Tween.start()
