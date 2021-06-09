extends CanvasLayer
const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + "save.dat"

func prove():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open(save_path, File.READ)
#var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var player_data = file.get_var()
			file.close()
			console_write(player_data["name"])
	
	console_write("data loaded")

func console_write(value):
	print(value)
	#console_label.text += str(value) + "\n"

func _ready():
	set_visible(false)

func _input(event):

	if event.is_action_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		set_visible(!get_tree().paused)
		get_tree().paused =! get_tree().paused
		#for _i in get_tree().get_root().get_children():
		#	print(_i.get_name())



func _on_Resume_pressed():
	get_tree().paused=false
	set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	

func set_visible(is_visible):
	for node in get_children():
		node.visible= is_visible


func _on_Full_Screen_pressed():
	OS.set_window_fullscreen(!OS.window_fullscreen)
	if OS.window_fullscreen==true:
		$VBoxContainer/FullScreen.text="Small Screen"
	else:
		$VBoxContainer/FullScreen.text="Full Screen"

func _on_Quit_pressed():
	var menu=load('res://UI/MarginContainer.tscn').instance()
	for c in get_tree().get_root().get_children():
		c.queue_free()
	get_tree().get_root().add_child(menu)

func _on_Save_pressed():
	var player_data = get_tree().get_root().get_node("World/Player").get_save_data()
	SaveSystem.save_player("Test1", player_data)
