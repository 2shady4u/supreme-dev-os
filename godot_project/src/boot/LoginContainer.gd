extends VBoxContainer

signal login_succeeded

const EMPLOYEE_ID := "000001"
const PASSWORD := "melissa"

func _ready():
	var _error := $LoginButton.connect("pressed", self, "_on_login_button_pressed")

	$Control/FailureLabel.visible = false

func _on_login_button_pressed():
	var employee_id : String =  $EmployeeHB/LineEdit.text
	var password : String = $PasswordHB/LineEdit.text

	if employee_id == EMPLOYEE_ID and password == PASSWORD:
		emit_signal("login_succeeded")
	else:
		$Control/FailureLabel.visible = true
		$EmployeeHB/LineEdit.text = ""
		$PasswordHB/LineEdit.text = ""
