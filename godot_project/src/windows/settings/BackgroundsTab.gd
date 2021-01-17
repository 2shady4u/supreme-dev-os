extends classSettingsTab

const SCENE_BACKGROUND_THUMBNAIL := preload("res://src/windows/settings/BackgroundThumbnail.tscn")

onready var _grid_container := $MC/VB/ScrollContainer/Grid
onready var _confirm_button := $MC/VB/ConfirmButton
onready var _browse_button := $MC/VB/BrowseButton

onready var _file_dialog := $FileDialog

var active_thumbnail : TextureButton setget set_active_thumbnail
func set_active_thumbnail(value : TextureButton):
	active_thumbnail = value
	if active_thumbnail:
		_confirm_button.disabled = false
	else:
		_confirm_button.disabled = true

func _ready():
	var _error := _confirm_button.connect("pressed", self, "_on_confirm_button_pressed")
	_error = _browse_button.connect("pressed", self, "_on_browse_button_presed")
	_error = _file_dialog.connect("file_selected", self, "_on_file_selected")

	_confirm_button.disabled = true

	# Here we need to find the available backgrounds!
	# This consists of:
	# - The default backgrounds
	# - Any "registered" backgrounds (???)
	for child in _grid_container.get_children():
		_grid_container.remove_child(child)
		child.queue_free()

	for texture in Flow.DEFAULT_BACKGROUNDS:
		var background_thumbnail := SCENE_BACKGROUND_THUMBNAIL.instance()

		background_thumbnail.texture = texture

		_error = background_thumbnail.connect("toggled", self, "_on_thumbnail_pressed", [background_thumbnail])
		_grid_container.add_child(background_thumbnail)

func _on_thumbnail_pressed(button_pressed : bool, thumbnail : TextureButton):
	if button_pressed:
		self.active_thumbnail = thumbnail
	elif active_thumbnail == thumbnail:
		self.active_thumbnail = null

	for child in _grid_container.get_children():
		if child != active_thumbnail and child.pressed:
			child.pressed = false

func _on_confirm_button_pressed():
	if active_thumbnail:
		var texture : Texture = active_thumbnail.texture
		State.background_texture = texture
	else:
		push_error("Confirm button should've been disabled!")

func _on_browse_button_presed():
	$FileDialog.popup_centered()

func _on_file_selected(path : String):
	var image = Image.new()
	var err = image.load(path)
	print(path)
	if err == OK:
		var texture = ImageTexture.new()
		texture.create_from_image(image, 0)

		State.background_texture = texture
