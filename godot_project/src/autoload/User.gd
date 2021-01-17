class_name classUser
extends Reference

var id := "" setget set_id
func set_id(value : String):
	id = value
	settings = Flow.USER_SETTINGS.get(id, {})
var settings := {}

var background_texture : Texture setget , get_background_texture
func get_background_texture() -> Texture:
	if background_texture:
		return background_texture
	else:
		return preload("res://graphics/backgrounds/background1.jpg")

var context : Dictionary setget set_context
func set_context(value : Dictionary) -> void:
	if not value.has("id"):
		push_error("User context requires id!")
		return

	self.id = value.id

# These are all constants derived from USER_SETTINGS and should be treated as such!
var name : Array setget , get_name
func get_name() -> Array:
	return settings.get("name", "MISSING NAME")

var is_root : Array setget , get_is_root
func get_is_root() -> Array:
	return settings.get("is_root", false)

var password : String setget , get_password
func get_password() -> String:
	return settings.get("password", "")

var portrait_texture : Texture setget , get_portrait_texture
func get_portrait_texture() -> Texture:
	return settings.get("portrait_texture", preload("res://graphics/startup/portrait_john.png"))

var greeting : AudioStream setget , get_greeting
func get_greeting() -> AudioStream:
	return settings.get("greeting", preload("res://resources/brenda/greetings/default_greeting.ogg"))
