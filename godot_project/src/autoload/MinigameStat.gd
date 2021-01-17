class_name classMinigameStat
extends Reference

var id := ""
var win := 0
var loss := 0
var stalemate := 0

var has_stalemate := true

var context : Dictionary setget set_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Program context requires id!")
		return

	id = value.id
	has_stalemate = value.get("has_stalemate", has_stalemate)

	win = value.get("win", win)
	loss = value.get("loss", loss)
	stalemate = value.get("stalemate", stalemate)
