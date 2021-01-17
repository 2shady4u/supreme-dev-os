extends MenuButton

onready var popup : Popup = get_popup()

enum ITEM {OPEN}

signal open_pressed

func _ready():
	popup.add_item("Open File", ITEM.OPEN)
	var _error : int = popup.connect("id_pressed", self, "_on_open_pressed")

func _on_open_pressed(_int_id : int) -> void:
	emit_signal("open_pressed")
