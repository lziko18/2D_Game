extends Control


var hearts= 1 setget set_hearts
var max_hearts = 1 setget set_max_hearts
onready var heartUIFull=$full
onready var heartUIEmpty=$empty
func set_hearts(value):
	hearts=clamp(value,0,max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts*15



func set_max_hearts(value):
	max_hearts = max(value,1)
	self.hearts=min(hearts,max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x=max_hearts*15

func _ready():
	self.max_hearts=PlayerStats.max_health
	self.hearts=PlayerStats.health
	var _hm=PlayerStats.connect("health_changed",self,"set_hearts")
	var _hm1=PlayerStats.connect("max_health_changed",self,"set_max_hearts")
