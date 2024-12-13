extends CanvasLayer
const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "masterPass.json"
const SECURITY_KEY = "2QPYVS2A"

@onready var checkLogon = $checkBox
var stored_data = storedData.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	stored_data.requiredLogin = true
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	if(stored_data.requiredLogin == true):
		checkLogon.visible = !checkLogon.visible
		
func save_data(path: String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if file != null:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		file.close()
	file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print ("get_open_error 1: ", FileAccess.get_open_error())

	var newData = {
		"stored_data":{
			"username": stored_data.username,
			"password": stored_data.password,
			"requiredLogin": stored_data.requiredLogin
		}
	}
	
	var json_string = JSON.stringify(newData, "\t")
	file.store_string(json_string)
	file.close()

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
		
		stored_data = storedData.new()
		stored_data.username = data.stored_data.username
		stored_data.password = data.stored_data.password
		stored_data.requiredLogin = data.stored_data.requiredLogin
	else:
		printerr("Cannot open non-existent file at %s!" % [path])


func _on_require_login_pressed():
	if(stored_data.requiredLogin == true):
		checkLogon.visible = !checkLogon.visible
		stored_data.requiredLogin = false
	else:
		checkLogon.visible = !checkLogon.visible
		stored_data.requiredLogin = true	
	print("required Login: ", stored_data.requiredLogin)
	save_data(SAVE_DIR + SAVE_FILE_NAME)
