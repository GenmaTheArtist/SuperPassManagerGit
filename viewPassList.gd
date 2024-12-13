extends Node2D

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "pList.json"
const SECURITY_KEY = "4234AF5B"

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

var stored_data = moreStoredData.new()

var accounts = TextEdit
var usernames = accounts
var passwords = accounts

# Called when the node enters the scene tree for the first time.
func _ready():
	accounts = $CanvasLayer/accountList
	usernames = $CanvasLayer/userList
	passwords = $CanvasLayer/passList
	
	initializeView()

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
		
		stored_data = moreStoredData.new()
		#stored_data.ID = data.stored_data.ID
		#stored_data.sitename = data.stored_data.sitename
		#stored_data.username = data.stored_data.username
		#stored_data.password = data.stored_data.password
		stored_data.array = data.stored_data.array
	else:
		printerr("Cannot open non-existent file at %s!" % [path])

func initializeView():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	accounts.text = ""
	usernames.text = ""
	passwords.text = ""
	var i = 0
	while (i <len(stored_data.array)):
		accounts.text += (stored_data.array[i+1] + "\n")
		usernames.text += (stored_data.array[i+2] + "\n")
		passwords.text += (stored_data.array[i+3] + "\n")
		i+=4

func delete(passedID: int):
	var i = 0
	while (i <len(stored_data.array)):
		if (stored_data.array[i] == passedID):
			deleteProcess(passedID, i, (SAVE_DIR + SAVE_FILE_NAME))
			return
		i+=4

func deleteProcess(passedID: int, arrayLoc: int, path: String):
	#checks if file exists
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY)
	if file != null:
		var content = file.get_as_text()
		var data = JSON.parse_string(content)
		stored_data.array = data.stored_data.array
		file.close()
	file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY)
	if file == null:
		print ("get_open_error 1: ", FileAccess.get_open_error())
	
	#delete process begins
	#var tempData = stored_data #unused variable
	
	var i = arrayLoc
	#Checks if the location is the start of the array
	#write empty contents if true.
	if (len(stored_data.array)<=i+4 && i == 0):
		stored_data = null
		var json_string = JSON.stringify(stored_data,"\t")
		file.store_string(json_string)
		file.close()
		get_tree().reload_current_scene()
		return
	
	#if not start of the array, continue
	#-----------------------------------
	
	#Initiliaze variables
	var appendtemp = [0,"","",""] 			#array used for appending data onto newtemp array
	
	var newtemp = appendtemp
	
	#writes data in newtemp up until it reaches the index being deleted.
	if (i != 0):
		var q = 0 								#used for incrementing the start of the array.
		newtemp = [stored_data.array[q], stored_data.array[q+1], stored_data.array[q+2], stored_data.array[q+3]]
		q+=4 #increments once data is initialized
		while (q < i):
			appendtemp = [stored_data.array[q], stored_data.array[q+1], stored_data.array[q+2], stored_data.array[q+3]]
			newtemp.append_array(appendtemp)
			q += 4
	else:
		newtemp = [stored_data.array[i], stored_data.array[i+5], stored_data.array[i+6], stored_data.array[i+7]]
		i+=4		
	#Skips to the next dataset in the array.
	#ID should be maintained from the one previously to keep continuity.
	if (i+4 != len(stored_data.array)):
		while (i+4 < len(stored_data.array)):
			appendtemp = [stored_data.array[i], stored_data.array[i+5], stored_data.array[i+6], stored_data.array[i+7]]
			newtemp.append_array(appendtemp)
			i += 4
	
	#stores newtemp into the stored_data
	stored_data.array = newtemp
	
	var newData = {
		"stored_data":{
			#"ID": stored_data.ID,
			#"sitename": stored_data.sitename,
			#"username": stored_data.username,
			#"password": stored_data.password,
			"array": stored_data.array
		}
	}
	
	var json_string = JSON.stringify(newData, "\t")
	file.store_string(json_string)
	file.close()
	get_tree().reload_current_scene()

#The rest of this page is button calls
func _on_del_1_pressed():
	delete(1)
func _on_del_2_pressed():
	delete(2)
func _on_del_3_pressed():
	delete(3)
func _on_del_4_pressed():
	delete(4)
func _on_del_5_pressed():
	delete(5)
func _on_del_6_pressed():
	delete(6)
func _on_del_7_pressed():
	delete(7)
func _on_del_8_pressed():
	delete(8)
func _on_del_9_pressed():
	delete(9)
func _on_del_10_pressed():
	delete(10)
func _on_del_11_pressed():
	delete(11)
func _on_del_12_pressed():
	delete(12)
func _on_del_13_pressed():
	delete(13)
func _on_del_14_pressed():
	delete(14)
func _on_del_15_pressed():
	delete(15)


func _on_button_pressed():
	get_tree().change_scene_to_file.bind("res://MainScreen.tscn").call_deferred()
