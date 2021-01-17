extends classSettingsTab

const NAME_TEXT := "Name: {0}"
const ID_TEXT := "Name: {0}"

onready var _id_edit := $MC/VB/VB/VB/IdHB/IdEdit
onready var _password_edit := $MC/VB/VB/VB/PasswordHB/PasswordEdit
onready var _status_label := $MC/VB/VB/Control/StatusLabel

func _ready():
	var _error := $MC/VB/VB/SwitchButton.connect("pressed", self, "_on_switch_button_pressed")

	var user : classUser = State.get_user_by_viewport(get_viewport())
	$MC/VB/HB/VB/VB/NameLabel.text = NAME_TEXT.format([user.name])
	$MC/VB/HB/VB/VB/IdLabel.text = NAME_TEXT.format([user.id])

	$MC/VB/HB/PortraitRect.texture = user.portrait_texture

	_status_label.visible = false

func _on_switch_button_pressed():
	var user_id : String = _id_edit.text
	if user_id in State.users.keys():
		State.user_id = user_id
		Flow.change_scene_to("startup", get_viewport())

	_status_label.visible = true
