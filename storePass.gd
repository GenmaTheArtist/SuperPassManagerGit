extends Node2D

#storePass
#This function stores user inputted data into an array in pList.json.
#This uses a similar method to the bootScreen, only a tad more complicated
#since this is using an array.
#--------------------------------------------------------------

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "pList.json"
const SECURITY_KEY = "4234AF5B"

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

var stored_data = moreStoredData.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#calls load_data
func initializeView():
	load_data(SAVE_DIR + SAVE_FILE_NAME)

#returns to Main Screen. Could be expanded to display results and additional UI elements.
func switch_to_results():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()

#verifies the save directory
func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)
	
#This function saves the data by appending a temp array onto the existing one, then
#write the expanded array into pList.json
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

	var tempData = stored_data
	
	
	if(stored_data.array[0] == 0):
		stored_data.array = [1, stored_data.sitename, stored_data.username, stored_data.password]
	else:
		var i = 0
		var ID = i+1
		
		while(i+3 <= len(stored_data.array)):
			ID= stored_data.array[i]+1
			i+=4
			#i > 59
		if(i > 59):
			var newData = {
				"stored_data":{
					"array": stored_data.array
				}
			}
			var json_string = JSON.stringify(newData, "\t")
			file.store_string(json_string)
			file.close()
		var tempArray = [ID, tempData.sitename, tempData.username,tempData.password]
		stored_data.array.append_array(tempArray)
		
	var newData = {
		"stored_data":{
			"ID": stored_data.ID,
			"sitename": stored_data.sitename,
			"username": stored_data.username,
			"password": stored_data.password,
			"array": stored_data.array
		}
	}
	
	var json_string = JSON.stringify(newData, "\t")
	file.store_string(json_string)
	file.close()

#loads the data from the file located at the path, then stores it in stored_data.
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
		#stored_data.sitename = data.stored_data.sitename
		#stored_data.username = data.stored_data.username
		#stored_data.password = data.stored_data.password
		stored_data.array = data.stored_data.array
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

#This is unused in this function, but if you wanted to implement password strength checks you can.
#at default, this is merely storing passwords that are already used elsewhere.
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

#when typing into field, dynamically assigns data to stored_data.username
func _on_sitename_text_changed(new_text):
	stored_data.sitename = new_text

#when enter key is hit assigns data to stored_data.username, then submits.
func _on_sitename_text_submitted(new_text):
	stored_data.sitename = new_text
	_on_submit_pressed()

#sitename is optional
#Checks if username and password fields are empty. If not, then saves and switches to main.
func _on_submit_pressed():
	if (stored_data.username == "" || stored_data.password == ""):
		print("missing username or password")
		return
	save_data(SAVE_DIR + SAVE_FILE_NAME)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	switch_to_results()

#returns back to the main screen.
func _on_button_pressed():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()
