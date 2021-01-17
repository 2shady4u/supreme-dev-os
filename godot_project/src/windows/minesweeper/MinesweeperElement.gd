class_name classMinesweeperElement
extends TextureRect

signal pressed

var index : int

var is_hidden := true setget set_is_hidden
func set_is_hidden(value : bool) -> void:
	is_hidden = value
	if not is_hidden:
		is_tagged = false
	update_texture()

var is_tagged := false setget set_is_tagged
func set_is_tagged(value : bool) -> void:
	if is_hidden:
		is_tagged = value
		update_texture()

var is_da_bomb := false
var neighbors_with_bombs := 0

func _ready():
	update_texture()

func update_texture():
	if is_tagged:
		texture = TAGGED_TEXTURE
	elif is_hidden:
		texture = HIDDEN_TEXTURE
	else:
		if is_da_bomb:
			texture = BOMB_TEXTURE
		else:
			texture = REVEALED_TEXTURES[neighbors_with_bombs]

func _gui_input(event):
	if event.is_action_pressed("LMB"):
		emit_signal("pressed", true)
	elif event.is_action_pressed("RMB"):
		emit_signal("pressed", false)

const HIDDEN_TEXTURE := preload("res://graphics/minesweeper/empty.png")
const TAGGED_TEXTURE := preload("res://graphics/minesweeper/tagged.png")
const BOMB_TEXTURE := preload("res://graphics/minesweeper/bomb.png")

const REVEALED_TEXTURES := {
	0: preload("res://graphics/minesweeper/0.png"),
	1: preload("res://graphics/minesweeper/1.png"),
	2: preload("res://graphics/minesweeper/2.png"),
	3: preload("res://graphics/minesweeper/3.png"),
	4: preload("res://graphics/minesweeper/4.png"),
	5: preload("res://graphics/minesweeper/5.png"),
	6: preload("res://graphics/minesweeper/6.png"),
	7: preload("res://graphics/minesweeper/7.png"),
	8: preload("res://graphics/minesweeper/8.png")
}
