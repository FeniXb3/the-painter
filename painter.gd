extends TextureRect

@export var image_size := Vector2i(128, 128)
@export_range(1, 10) var brush_size := 4
@export var background_color := Color.WHITE
@export var brush_color := Color.BLACK
var image: Image

func _ready() -> void:
	image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(background_color)
	texture = ImageTexture.create_from_image(image)


func _process(_delta: float) -> void:
	var mouse_position: Vector2i = get_local_mouse_position()
	if not Rect2(Vector2(), size).has_point(mouse_position):
		return
		
	if Input.is_action_pressed("draw"):
		draw_brush(mouse_position, brush_color)
	if Input.is_action_pressed("erase"):
		draw_brush(mouse_position, background_color)
		
func draw_brush(brush_position: Vector2, color: Color):
	var proportion := Vector2(1, 1)
	if stretch_mode == StretchMode.STRETCH_KEEP_ASPECT:
		var min_axis_index := size.min_axis_index()
		proportion = image.get_size() / size[min_axis_index]
	
	
	for x in brush_size:
		for y in brush_size:
			var pixel_position := brush_position * proportion + Vector2(x-brush_size/2, y - brush_size/2)
			pixel_position = pixel_position.clamp(Vector2i(), image.get_size() - Vector2i(1, 1))
			image.set_pixelv(pixel_position, color)
	texture = ImageTexture.create_from_image(image)
