class_name classTicTacToeElement
extends TextureRect

signal pressed

enum HOLDER {NONE, PLAYER, AI}

var magic_number := 0
var holder : int = HOLDER.NONE setget set_holder
func set_holder(value : int):
	holder = value
	update_texture()

func _ready():
	update_texture()

func update_texture():
	texture = TEXTURE_SETTINGS[holder]

func _gui_input(event):
	if event.is_action_pressed("LMB"):
		emit_signal("pressed")

const TEXTURE_SETTINGS := {
	HOLDER.NONE: preload("res://graphics/tic_tac_toe/empty.png"),
	HOLDER.PLAYER: preload("res://graphics/tic_tac_toe/cross.png"),
	HOLDER.AI: preload("res://graphics/tic_tac_toe/circle.png"),
}
