extends Node

const REFERENCE_PROGRAM := preload("res://src/autoload/Program.gd")
const REFERENCE_USER := preload("res://src/autoload/User.gd")
const REFERENCE_MINIGAME_STAT := preload("res://src/autoload/MinigameStat.gd")

const DEFAULT_CONTEXT_PATH := "res://default_context.json"

var fetched_mails := false
var dropped_passwords := false

signal background_changed
signal programs_changed

func _ready():
	var _error : int = load_stateJSON()

	clear_user_directory()

	copy_folder_content("res://copy_to_user", "user://")
	add_random_crash_logs()

	# Some kind of race condition here... ignore for now!
	copy_folder_content("res://personal_folders/{0}".format([user_id]), "user://personal/")

func load_stateJSON(path : String = DEFAULT_CONTEXT_PATH) -> int:
	var context : Dictionary = Flow.load_JSON(path)
	if not context.empty():
		load_state_from_context(context)
		return OK
	else:
		return ERR_FILE_CORRUPT

func load_state_from_context(context : Dictionary) -> void:
	programs.clear()
	minigame_stats.clear()
	users.clear()

	init_users()

	for program_context in context.get("programs", []):
		add_program_from_context(program_context)

	for minigame_stat_context in context.get("minigame_stats", []):
		add_minigame_stat_from_context(minigame_stat_context)

	self.user_id = context.get("user_id", user_id)

## CURRENT USER ###############################################################
var user_id := "john_doe" setget set_user_id
func set_user_id(value : String):
	user_id = value
	if users.has(user_id):
		user = users[user_id]
		# Swap out the personal folder!!!
		_delete_directory_recursive("user://personal")
		copy_folder_content("res://personal_folders/{0}".format([user_id]), "user://personal/")
	else:
		push_error("User with id is not present in the known group of users!")

var user : classUser

func get_user_by_viewport(viewport : Viewport):
	if viewport == get_tree().get_root():
		return user
	else:
		return users["brock_zhu"]

var background_texture : Texture setget set_background_texture, get_background_texture
func set_background_texture(value : Texture):
	user.background_texture = value
	emit_signal("background_changed", value)
func get_background_texture() -> Texture:
	if user:
		return user.background_texture
	else:
		return null

## USERS ######################################################################
var users := {}

func init_users() -> void:
	for id in Flow.USER_SETTINGS.keys():
		var _user := REFERENCE_USER.new()
		_user.id = id

		print("Adding registered user with id '{0}' to State!".format([id]))
		users[id] = _user

## PROGRAMS ###################################################################
var programs := {}

func add_program_from_context(program_context : Dictionary) -> void:
	var program := REFERENCE_PROGRAM.new()
	program.context = program_context

	programs[program.id] = program

func add_program_by_id(program_id : String) -> void:
	var program := REFERENCE_PROGRAM.new()
	program.id = program_id

	print("Adding brand-new program with id '{0}' to State!".format([program_id]))
	programs[program.id] = program
	emit_signal("programs_changed")

func remove_program_by_id(program_id : String) -> void:
	var success := programs.erase(program_id)
	if not success:
		push_error("Program with id '{0}' was not found in State!".format([program_id]))

func get_program_by_id(program_id : String) -> classProgram:
	if program_id in programs.keys():
		return programs[program_id]
	return null

func has_program(program_id : String) -> bool:
	if get_program_by_id(program_id):
		return true
	else:
		return false

# MINIGAME STATISTICS #########################################################
var minigame_stats := {}

func add_minigame_stat_from_context(minigame_stat_context : Dictionary) -> void:
	var minigame_stat := REFERENCE_MINIGAME_STAT.new()
	minigame_stat.context = minigame_stat_context

	minigame_stats[minigame_stat.id] = minigame_stat

func add_minigame_stat_by_id(minigame_id : String) -> void:
	var _minigame_stat := add_and_return_minigame_stat_by_id(minigame_id)

func add_and_return_minigame_stat_by_id(minigame_id : String) -> classMinigameStat:
	var minigame_stat := REFERENCE_MINIGAME_STAT.new()
	minigame_stat.id = minigame_id

	print("Adding brand-new minigame statistic with id '{0}' to State!".format([minigame_id]))
	minigame_stats[minigame_stat.id] = minigame_stat

	return minigame_stat

func get_minigame_stat_by_id(minigame_id : String) -> classMinigameStat:
	if minigame_id in minigame_stats.keys():
		return minigame_stats[minigame_id]
	return null

# CRASH LOGS  ##################################################################

const HIDDEN_MESSAGE := "Olympus could not satisfy loading dependency of the `ENC` file format!\nRECOMMENDATION: install program `enigma_encryptor` to be able to load `ENC` file format."

const FAKE_MESSAGES := [
	"Pantheon Inc. DRM certification module (v1.2) requires urgent update!\nPlease update immediately so satisfactory user experience can be ensured.",
	"Failed to initialize Baracuda X99-A graphics driver (v0.1)\nProgram `Terminal.exe` requires minimum version 0.2",
	"Pantheon Inc. has detected illegal activity on this host device and can no longer function.\nAll your files are scheduled for immediate deletion.",
	"Failed to start `crash_manager` due to segmentation fault in main thread.\nRECOMMENDATION: Use program `crash_manager` to debug for segmentation faults.",
	"Supreme Dev OS encountered race condition during start-up.\nRECOMMENDATION: Manually reduce CPU clock speed to avoid race condition.",
	"Multiple programs tried to access the same file at once.\nDeadlock timeout timer ran out of time.",
	"Failed to initialize Ninja Master audio driver (v8.5)\nProgram `BrendAI.exe` requires minimum version 9.1",
]

func add_random_crash_logs():
	var datetime := {}
	datetime.year = 2021
	datetime.month = 01
	var possible_days := range(1, 20)
	var message := ""

	var number_of_fake_messages := 48
	for _i in range(number_of_fake_messages):
		datetime.day = possible_days[randi() % possible_days.size()]

		datetime.hour = randi() % 24
		datetime.minute = randi() % 60
		datetime.second = randi() % 60

		message = FAKE_MESSAGES[randi() % FAKE_MESSAGES.size()]
		save_crash_log(message, datetime)

		if _i == int(float(number_of_fake_messages)/2.0):
			# NOW ADD THE HIDDEN MESSAGE!!!
			# has the be added at the 8th because that's the day Hana downloaded the encryption software.
			datetime.day = 8

			datetime.hour = randi() % 24
			datetime.minute = randi() % 60
			datetime.second = randi() % 60
			message = HIDDEN_MESSAGE
			save_crash_log(message, datetime)

func add_crash_log() -> void:
	save_crash_log(Flow.failure_message, OS.get_datetime())

func save_crash_log(message : String, datetime : Dictionary) -> void:
	var content := "- SUPREME DEV OS CRASH DUMP -\n"
	content += "DATE: {month}/{day}/{year}\n".format(datetime)
	content += "TIME: {hour}:{minute}:{second}\n".format(datetime)
	content += "DUMP START ---\n"
	content += message + "\n"
	content += "--- DUMP END"

	var folder := "user://crash_dumps/%02d%02d%02d" % [datetime.month, datetime.day, datetime.year]
	var path : String = folder + "/dump"
	var path_ext : String = path + ".txt"

	var dir := Directory.new()
	var _error : int = dir.make_dir_recursive(folder)
	var index := 1
	while dir.file_exists(path_ext):
		path_ext = "{0}({1}).txt".format([path, index])
		index += 1

	Flow.save_TXT(path_ext, content)

func clear_user_directory():
	var dir : Directory = Directory.new()
	if dir.open("user://") == OK:
		var _error = dir.list_dir_begin(true);
		var file_name : String = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				_delete_directory_recursive("{0}{1}".format(["user://", file_name]))
				_error = dir.remove("user://" + file_name)
			else:
				_error = dir.remove("user://" + file_name)
			file_name = dir.get_next()
	else:
		push_error("Unable to open 'user://'-folder")

func _delete_directory_recursive(source_folder : String):
	var dir : Directory = Directory.new()
	if dir.open(source_folder) == OK:
		var _error = dir.list_dir_begin(true);
		var file_name : String = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				_delete_directory_recursive("{0}/{1}".format([source_folder, file_name]))
				_error = dir.remove(source_folder + "/" + file_name)
			else:
				_error = dir.remove(source_folder + "/" + file_name)
			file_name = dir.get_next()
	else:
		push_error("Unable to open '{0}'-folder".format([source_folder]))

func copy_folder_content(source_folder, target_folder):
	#print("Copying...")

	var dir : Directory = Directory.new()
	var _error := OK
	if not dir.dir_exists(target_folder):
		_error = dir.make_dir_recursive(target_folder)

	if dir.open(source_folder) == OK:
		#print("Copying...2")
		_error = dir.list_dir_begin(true)
		var file_name : String = dir.get_next()
		while (file_name != ""):
			#print(file_name)
			if dir.current_is_dir():
				copy_folder_content("{0}/{1}".format([source_folder, file_name]), "{0}/{1}".format([target_folder, file_name]))
			else:
				if file_name.get_extension() != "pngx":
					_error = dir.copy(source_folder + "/" + file_name, target_folder + "/" + file_name)
				else:
					var modified_file_name := file_name.get_basename() + ".png"
					_error = dir.copy(source_folder + "/" + file_name, target_folder + "/" + modified_file_name)
					#print(_error)
			file_name = dir.get_next()
	else:
		print("Could not open data folder (%s)."%[source_folder])
