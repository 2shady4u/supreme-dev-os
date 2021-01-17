extends ScrollContainer

func _ready():
	reset_content()
	$VB/DefaultLabel.visible = true

func reset_content():
	$VB/Label.visible = false
	$VB/TextureRect.visible = false
	$VB/DefaultLabel.visible = false

func update_content(path):
	reset_content()

	match path.get_extension():
		"txt", "enc":
			var content : String = Flow.load_TXT(path)
			$VB/Label.text = content
			$VB/Label.visible = true
		"png":
			var image = Image.new()
			var err = image.load(path)
			if err == OK:
				var texture = ImageTexture.new()
				texture.create_from_image(image, 0)

				$VB/TextureRect.texture = texture
			$VB/TextureRect.visible = true
