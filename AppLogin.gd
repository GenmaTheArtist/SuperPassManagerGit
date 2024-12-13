extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "masterPass.json"
const SECURITY_KEY = "2QPYVS2A"

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

@onready var textResults = $generalText/results
var stored_data = storedData.new()
var temp_data = stored_data

# Called when the node enters the scene tree for the first time.
func _ready():
	verify_save_directory(SAVE_DIR)
	var path = SAVE_DIR + SAVE_FILE_NAME
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if (file == null):
		switch_to_boot()	
	if (file != null):
		load_data(SAVE_DIR + SAVE_FILE_NAME)
		
func switch_to_boot():
	get_tree().change_scene_to_file.bind("res://boot_screen.tscn").call_deferred()
	
func switch_to_main():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func load_data(path: String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
		if file == null:
			print("get_open_error 2: ", FileAccess.get_open_error())
			return
		
		var content = file.get_as_text()
		file.close()
	
		var data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot parse: ", "Cannot parse %s as a json_string: (%s)" % [path, content])
			return
		temp_data.username = data.stored_data.username
		temp_data.password = data.stored_data.password
		#stored_data.array = data.stored_data.array
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func _on_username_text_changed(new_text):
	stored_data.username = new_text

func _on_username_text_submitted(new_text):
	stored_data.username = new_text
	_on_submit_pressed()

func _on_submit_pressed():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	if(!textResults.is_visible_in_tree()):
		textResults.visible = !textResults.visible
	if (stored_data.password == "" || stored_data.username == ""):
		textResults.text = "[center] Missing Username or Password."
		return
	load(SAVE_DIR + SAVE_FILE_NAME)
	if (temp_data.username != stored_data.username || temp_data.password != stored_data.password):
		textResults.text = "[center] Username or Password is incorrect."
		return
	switch_to_main()
	

func _on_password_text_changed(new_text):
	stored_data.password = new_text


func _on_password_text_submitted(new_text):
	stored_data.password = new_text
	_on_submit_pressed()
