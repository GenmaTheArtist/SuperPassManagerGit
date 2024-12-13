extends Node2D

#bootScreen
#> The default screen of the application. Used to set Master username + password.
#> Upon boot, checks to see if masterPass exists and if requiredLogin is true.
#If both are true, then the screen switches to AppLogin
#> Otherwise this program asks the user to input their 
#Master username and password. Then, if it matches the strength requirements
#then it switches to the confirmation screen.
#> At the confirmation screen you are given a chance to copy the data elsewhere.
#> When Submit is pressed, data is written to masterPass.json and switches to 
#the main screen.
#> At the confirmation screen you can click a toggle to set whether you want
#to be asked to Login every single time.
#
#
#IMPORTANT:
#User is expected to keep their Master username and password elsewhere
#for security purposes. This is not the most efficient form of security,
#but it is how this application works.
#This way you only need to remember one password.
#--------------------------------------------------------------

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
	#
	if (file == null):
		print ("get_open_error onBoot: ", FileAccess.get_open_error())
	if (file != null):
		checkRequired(path)

#switches to the Main Screen.
func switch_to_main():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()

#switches to the AppLogin screen.
func switch_to_login():
	get_tree().change_scene_to_file.bind("res://AppLogin.tscn").call_deferred()

#verifies save directory
func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
#This function write the contents of stored_data to masterPass.json
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

#This function is called by _ready if masterPass.json exists. 
#It checks requiredLogin and decides which screen this application will be switching to.
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

#This function reads masterPass.json and copies its contents to stored_data.
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

#This function takes in a string, and a number of unique characters.
#It then compares the string to keyTerms, and increments minNum for each one it finds.
#returns true if i >= minNum
func testPassword(new_pass: String, minNum: int):
	#new_pass is a string being checked for characters
	#minNum is the number of characters being checked for
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
	if (tempInt >= minNum):
		return true
	else:
		return false

#This is currently Unused. But was written last minute to potentially delete pList.json
#This is a security measure, that can possibly be implemented in the future.
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

#when typing into field, dynamically assigns data to stored_data.username
func _on_username_text_changed(new_text):
	stored_data.username = new_text

#when enter key is hit assigns data to stored_data.username, then submits.
func _on_username_text_submitted(new_text):
	stored_data.username = new_text
	_on_submit_pressed()
	
#when typing into field, dynamically assigns data to stored_data.username
func _on_password_text_changed(new_text):
	stored_data.password = new_text
	
#when enter key is hit assigns data to stored_data.username, then submits.
func _on_password_text_submitted(new_text):
	stored_data.password = new_text	
	_on_submit_pressed()

#This is the initial submit button.
#This checks if username and password fields are filled out.
#Then calles testpassword to test password strength.
#then switches to the confirmation UI.
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
	
#This is used to toggle whether requireLogin will be required.
#It also toggles the graphic.
func _on_require_login_pressed():
	if(stored_data.requiredLogin == true):
		logonCheck.visible = !logonCheck.visible
		stored_data.requiredLogin = false
	else:
		logonCheck.visible = !logonCheck.visible
		stored_data.requiredLogin = true	

#This function is used to call the save function and then switches to
#the main screen.
func _on_final_confirm_pressed():
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	#unused code, may be implemented later
	var i = 0
	if(del_data != null):
		while (i <len(del_data.array)):
			#print("loaded the id: ", del_data.array[i], "\n")
			#print("loaded the username: ", del_data.array[i+1], "\n")
			#print("loaded the password: ", del_data.array[i+2], "\n")
			i+=3
	#end of unused code
	switch_to_main()


func _on_cancel_pressed():
	confScreen.visible = !confScreen.visible
	normScreen.visible = !normScreen.visible
