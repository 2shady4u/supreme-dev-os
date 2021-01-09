extends MenuButton

onready var popup : Popup = get_popup()

enum ITEM {LOG_OUT}

func _ready():
	popup.add_item("Log Out", ITEM.LOG_OUT)
	var _error : int = popup.connect("id_pressed", self, "_on_log_out_pressed")

func _on_log_out_pressed(_int_id : int) -> void:
	Flow.change_scene_to("startup")
