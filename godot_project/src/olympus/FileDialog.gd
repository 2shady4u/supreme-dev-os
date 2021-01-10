extends FileDialog

func _ready():
	set_filters(PoolStringArray([
		"*.txt ; TXT files",
		"*.import ; PNG images",
		"*.enc ; ENC files"
		]))
