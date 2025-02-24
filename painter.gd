extends TextureRect

@export var image_size := Vector2i(128, 128)
@export_range(1, 100) var brush_size := 4
@export var brush_color: Color = Color.BLACK
@export var background_color: Color = Color.WHITE
var image: Image

func _ready() -> void:
	image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(background_color)
	texture = ImageTexture.create_from_image(image)

func _process(_delta: float) -> void:
	var mouse_position: Vector2i = get_local_mouse_position()
	if not image.get_used_rect().has_point(mouse_position):
		return
	
	if Input.is_action_pressed("draw"):
		_draw_brush_stroke(mouse_position, brush_color)
	elif Input.is_action_pressed("erase"):
		_draw_brush_stroke(mouse_position, background_color)

func _draw_brush_stroke(cursor_position: Vector2i, color: Color):
		@warning_ignore("integer_division")
		var min_range: int = -brush_size/2
		for x in range(min_range, brush_size - min_range):
			for y in range(min_range, brush_size - min_range):
				var pixel_position := cursor_position + Vector2i(x, y)
				pixel_position = pixel_position.clamp(Vector2i(), image.get_size() - Vector2i(1, 1))
				image.set_pixelv(pixel_position, color)
		texture = ImageTexture.create_from_image(image)
