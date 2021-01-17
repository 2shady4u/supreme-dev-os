extends TextureButton

signal thumbnail_pressed

var texture : Texture setget set_texture
func set_texture(value : Texture):
	texture = value
	if is_inside_tree():
		$TextureRect.texture = texture

func _ready():
	var _error := connect("pressed", self, "_on_button_pressed")

	$TextureRect.texture = texture

func _on_button_pressed():
	emit_signal("thumbnail_pressed")
