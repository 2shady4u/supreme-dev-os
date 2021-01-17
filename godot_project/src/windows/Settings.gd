extends classWindow

onready var _settings_tab_container := $VB/HB/SettingsTabContainer

func _ready():
	for child in $VB/HB/VB/ScrollContainer/leftVB.get_children():
		if child is Button:
			child.connect("pressed", self, "_on_settings_button_pressed", [child.tab_type])

	self.header_text = "Supreme Settings"

func _on_settings_button_pressed(tab_type : int):
	_settings_tab_container.set_current_tab(tab_type)
