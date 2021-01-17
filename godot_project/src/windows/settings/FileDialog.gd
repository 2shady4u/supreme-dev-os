extends FileDialog

func _ready():
	set_filters(PoolStringArray([
		"*.import ; PNG images"
		]))
