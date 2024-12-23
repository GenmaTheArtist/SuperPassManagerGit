extends Control

#Main Screen
#> This screen is a menu.
#>The options are 'store Password' and 'view List'
#> The screen also features a toggle which changes masterPass.json's requiredLogin value.
#This toggle interacts with checkMaster.gd.
#>Clicking on either button will take you to either 'storePass' or 'viewPassList'
#>When "store" is clicked this program reads the number of entries in pList.
#if the number of entries is greater than or equal to the max, user will be asked to
#delete some entries using viewPassList, and will lock the store button.
#--------------------------------------------------------------

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "pList.json"
const SECURITY_KEY = "4234AF5B"

var keyTerms = ['.','!','_', '@', '#','$','%','&','*','/','0','1','2','3','4','5','6','7','8','9']

var stored_data = moreStoredData.new()

@onready var maxPassword = $CanvasLayer/maxReached
@onready var storeBttn = $CanvasLayer/Store

#stores the data located in pList into stored_data
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

#changes scene to ViewPassList upon clicking the button.
func _on_view_pressed():
	#get_tree().change_scene_to_file.bind("").call_deferred()
	#insert scene traversing to
	change_scene("res://viewPassList.tscn")

#Used for switching scenes. Arguably unnecessary. 
func change_scene(passed_address: String):
	get_tree().change_scene_to_file.bind(passed_address).call_deferred()

#Checks if the max number of passwords have been reached.
#If the max number of passwords is reached, displays error message and
#locks the button.
#else switches to the store_pass scene.
func _on_store_pressed():
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	var i = 0
	while (i < len(stored_data.array)):
		i+=1
	if(i >= 59):
		storeBttn.disabled = !storeBttn.disabled
		maxPassword.visible = !maxPassword.visible
		return
	change_scene("res://store_pass.tscn")
