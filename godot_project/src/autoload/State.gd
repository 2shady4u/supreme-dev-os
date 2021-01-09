extends Node

const REFERENCE_PROGRAM := preload("res://src/autoload/Program.gd")

const DEFAULT_CONTEXT_PATH := "res://default_context.json"

func _ready():
	var _error : int = load_stateJSON()

func load_stateJSON(path : String = DEFAULT_CONTEXT_PATH) -> int:
	var context : Dictionary = Flow.load_JSON(path)
	if not context.empty():
		load_state_from_context(context)
		return OK
	else:
		return ERR_FILE_CORRUPT

func load_state_from_context(context : Dictionary) -> void:
	programs.clear()

	for program_context in context.get("programs", []):
		add_program_from_context(program_context)

## PROGRAMS ####################################################################
var programs := {}

func add_program_from_context(program_context : Dictionary) -> void:
	var program := REFERENCE_PROGRAM.new()
	program.context = program_context

	programs[program.id] = program

func add_program_by_id(program_id : String) -> void:
	var program := REFERENCE_PROGRAM.new()
	program.id = program_id

	print("Adding brand-new program with id '{0}' to State!".format([program_id]))
	programs[program.id] = program

func remove_program_by_id(program_id : String) -> void:
	var success := programs.erase(program_id)
	if not success:
		push_error("Program with id '{0}' was not found in State!".format([program_id]))

func get_program_by_id(program_id : String) -> classProgram:
	if program_id in programs.keys():
		return programs[program_id]
	return null

func has_program(program_id : String) -> bool:
	if get_program_by_id(program_id):
		return true
	else:
		return false
