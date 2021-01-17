extends HBoxContainer

var editable : bool setget set_editable
func set_editable(value : bool) -> void:
	editable = value
	if is_inside_tree():
		$LineEdit.editable = editable

var text : String setget , get_text
func get_text() -> String:
	return $LineEdit.text

func _ready():
	pass

func give_focus_to_edit():
	$LineEdit.grab_focus()
