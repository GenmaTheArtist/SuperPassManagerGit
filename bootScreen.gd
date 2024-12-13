extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "masterPass.json"
const SECURITY_KEY = "2QPYVS2A"
const DEL_SAVE = "pList.json"
const DEL_KEY = "4234AF5B"

@onready var confScreen = $ConfirmationLayer
@onready var normScreen = $NormalLayer
@onready var logonCheck = $ConfirmationLayer/checkBox
@onready var userConf = $ConfirmationLayer/userConfirm
@onready var passConf = $ConfirmationLayer/passConfirm
@onready var passFailed = $NormalLayer/passFail
@onready var pass1 = $NormalLayer/password
@onready var pass2 = $ConfirmationLayer/passConfirm

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

var stored_data = storedData.new()
var del_data = moreStoredData.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	verify_save_directory(SAVE_DIR)
	var path = SAVE_DIR + SAVE_FILE_NAME
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if (file == null):
		#deleteSavedKeys(SAVE_DIR + DEL_SAVE)
		print ("get_open_error onBoot: ", FileAccess.get_open_error())
	if (file != null):
		checkRequired(path)

func switch_to_main():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()

func switch_to_login():
	get_tree().change_scene_to_file.bind("res://AppLogin.tscn").call_deferred()

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
func save_data(path: String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if file != null:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		if (data != null):
			stored_data.array = data.stored_data.array
		file.close()
	file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print ("get_open_error 1: ", FileAccess.get_open_error())
			
	#stored_data.ID[0] = 1 #debug code
		
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

func checkRequired(path: String):
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
		if(data.stored_data.requiredLogin == true && data.stored_data.requiredLogin != null):
			get_tree().change_scene_to_file.bind("res://AppLogin.tscn").call_deferred()
		else:
			get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

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
		#stored_data.ID = data.stored_data.ID
		stored_data.username = data.stored_data.username
		stored_data.password = data.stored_data.password
		#stored_data.array = data.stored_data.array
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func testPassword(new_pass: String, minNum: int):
	#new_pass is a string being checked for characters
	#minNum is the number of characters being checked for
	print("testPassword received ", new_pass)
	print("password length: ", new_pass.length())
	var tempInt = 0
	if (len(new_pass) <= 8):
		print("incorrect number of characters")
		return false
	var i = 0
	while (i<len(keyTerms)):
		if(new_pass.contains(keyTerms[i])):
			tempInt += 1
		i+=1
	print("number of characters is: ", tempInt, "\n")
	if (tempInt > minNum):
		return true
	else:
		return false

func deleteSavedKeys(path: String):
	#checks if file exists
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, DEL_KEY)
	if file != null:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		#del_data.array = data.stored_data.array
		file.close()
	#checks if file exists
	
	file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, DEL_KEY)
	if file == null:
		del_data = null
		print ("get_open_error 1: ", FileAccess.get_open_error())
	del_data = null	
	var json_string = JSON.stringify(del_data,"\t")
	file.store_string(json_string)
	file.close()
	return

func _on_username_text_changed(new_text):
	stored_data.username = new_text


func _on_username_text_submitted(new_text):
	stored_data.username = new_text
	_on_submit_pressed()
	

func _on_password_text_changed(new_text):
	stored_data.password = new_text
	

func _on_password_text_submitted(new_text):
	stored_data.password = new_text	
	_on_submit_pressed()

func _on_submit_pressed():
	if(!passFailed.is_visible_in_tree()):
		passFailed.visible = !passFailed.visible
	if (stored_data.username == "" || stored_data.password == ""):
		print("missing username or password")
		passFailed.text = "[center]Username or Password is empty."
		return
	if (!testPassword(stored_data.password,1)):	
		print("Please input a stronger password")
		passFailed.text = "[center]Please input a stronger password."
		return
	userConf.text = stored_data.username
	passConf.text = stored_data.password
	passFailed.visible = !passFailed.visible
	confScreen.visible = !confScreen.visible
	normScreen.visible = !normScreen.visible
	

func _on_require_login_pressed():
	if(stored_data.requiredLogin == true):
		logonCheck.visible = !logonCheck.visible
		stored_data.requiredLogin = false
	else:
		logonCheck.visible = !logonCheck.visible
		stored_data.requiredLogin = true	


func _on_final_confirm_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	print("username is ", stored_data.username)
	print("password is ", stored_data.password)
	var i = 0
	if(del_data != null):
		while (i <len(del_data.array)):
			#print("loaded the id: ", del_data.array[i], "\n")
			#print("loaded the username: ", del_data.array[i+1], "\n")
			#print("loaded the password: ", del_data.array[i+2], "\n")
			i+=3
	switch_to_main()


func _on_cancel_pressed():
	confScreen.visible = !confScreen.visible
	normScreen.visible = !normScreen.visible
