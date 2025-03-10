extends TextureRect

@export var image_size := Vector2i(128, 128)
@export_range(1, 10) var brush_size := 4
var image: Image

func _ready() -> void:
	image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	texture = ImageTexture.create_from_image(image)


func _process(delta: float) -> void:
	var mouse_position: Vector2i = get_local_mouse_position()
	if mouse_position.x < 0 or mouse_position.y < 0 or mouse_position.x >= image.get_size().x or mouse_position.y >= image.get_size().y:
		return
		
	if Input.is_action_pressed("draw"):
		draw_brush(mouse_position)
		
func draw_brush(brush_position: Vector2i):
	for x in brush_size:
		for y in brush_size:
			var pixel_position := brush_position + Vector2i(x-brush_size/2, y - brush_size/2)
			pixel_position = pixel_position.clamp(Vector2i(), image.get_size() - Vector2i(1, 1))
			image.set_pixelv(pixel_position, Color.BLACK)
	texture = ImageTexture.create_from_image(image)
