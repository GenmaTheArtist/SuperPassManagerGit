extends Node2D

#Unused test code for an unused screen.

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "inputPass.json"
const SECURITY_KEY = "4234AF5B"

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

var stored_data = storedData.new()

func _ready():
	verify_save_directory(SAVE_DIR)
	var path = SAVE_DIR + SAVE_FILE_NAME
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if (file == null):
		print ("get_open_error onBoot: ", FileAccess.get_open_error())
	if (file != null):
		switch_to_main()

func switch_to_main():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
func save_data(path: String):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if file != null:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		stored_data.array = data.stored_data.array
		file.close()
	file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print ("get_open_error 1: ", FileAccess.get_open_error())
		
	#stored_data.ID[0] = 1 #debug code
	var tempData = stored_data
	
	
	if(stored_data.array[0] == 0):
		stored_data.array = [1, stored_data.username, stored_data.password]
	else:
		
		var i = 0
		var ID = i+1
		
		while(i+3 <= len(stored_data.array)):
			ID= stored_data.array[i]+1
			i+=3
		var tempArray = [ID, tempData.username,tempData.password]
		stored_data.array.append_array(tempArray)	

	var newData = {
		"stored_data":{
			"ID": stored_data.ID,
			"username": stored_data.username,
			"password": stored_data.password,
			"array": stored_data.array
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
		stored_data.ID = data.stored_data.ID
		stored_data.username = data.stored_data.username
		stored_data.password = data.stored_data.password
		stored_data.array = data.stored_data.array
		
		
		
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func testPassword(new_pass: String, minNum: int):
	var tempInt = 0
	if (len(new_pass) < 8):
		return false
	var i = 0
	while (i<len(keyTerms)):
		if(new_pass.contains(keyTerms[i])):
			tempInt += 1
		i+=1
	#print("number of characters is: ", tempInt, "\n")
	if (tempInt >= minNum):
		return true

func _on_submit_pressed():
	if (stored_data.username == "" || stored_data.password == ""):
		print("missing username or password")
		return
	save_data(SAVE_DIR + SAVE_FILE_NAME)


func _on_password_text_submitted(new_text):
	stored_data.password = new_text
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	if(stored_data.username != ""):
		load_data(SAVE_DIR + SAVE_FILE_NAME)

func _on_password_text_changed(new_text):
	stored_data.password = new_text


func _on_username_text_changed(new_text):
	stored_data.username = new_text


func _on_username_text_submitted(new_text):
	stored_data.username = new_text
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	if(stored_data.password != ""):
		load_data(SAVE_DIR + SAVE_FILE_NAME) # Replace with function body.


func _on_load_pressed():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	var i = 0
	while (i <len(stored_data.array)):
		print("loaded the id: ", stored_data.array[i], "\n")
		print("loaded the username: ", stored_data.array[i+1], "\n")
		print("loaded the password: ", stored_data.array[i+2], "\n")
		i+=3


func _on_test_pass_pressed():
	if (testPassword(stored_data.password, 1)):
		print("password is strong")
	else:
		print("type a stronger password.")
