extends FileDialog

func _ready():
	set_filters(PoolStringArray([
		"*.txt ; TXT files",
		"*.png ; PNG images",
		"*.enc ; ENC files"
		]))
