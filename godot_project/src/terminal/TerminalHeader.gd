extends VBoxContainer

func _ready():
	var supreme_dev_os : classProgram = State.get_program_by_id("supreme_dev_os")

	$Label.text = "\nSupreme Dev OS (v{0}) - TERMINAL\n".format([supreme_dev_os.version])
	$Label.text += "New here? Type `help` to get a handy list of commands!\n"
