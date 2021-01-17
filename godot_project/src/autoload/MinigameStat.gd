class_name classMinigameStat
extends Reference

var id := ""
var loss := 0
var win := 0
var stalemate := 0

var has_stalemate := true

var context : Dictionary setget set_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("Program context requires id!")
		return

	id = value.id
	loss = value.get("loss", self.default_version)
	loss = value.get("loss", self.default_version)
