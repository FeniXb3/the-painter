@tool
extends TextureRect

@export var image_size := Vector2i(128, 128)
@export_range(1, 10) var brush_size : float = 4
@export var brush_increment_step: int = 2
@export var background_color := Color.WHITE
@export var brush_color := Color.BLACK
@export var brush_texture: Texture2D:
	set(value):
		brush_texture = value
		brush_image = brush_texture.get_image()
var image: Image
var brush_image: Image
var is_active: bool = false

func _ready() -> void:
	image = Image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(background_color)
	texture = ImageTexture.create_from_image(image)
	
func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("increase_brush_size"):
		brush_size += brush_increment_step
	elif event.is_action_pressed("decrease_brush_size"):
		brush_size -= brush_increment_step


func _process(_delta: float) -> void:
	var mouse_position: Vector2i = get_local_mouse_position()
	if not Rect2(Vector2(), size).has_point(mouse_position):
		return
		
	if Engine.is_editor_hint():
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			draw_brush(mouse_position, get_brush_texture_pixel)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			draw_brush(mouse_position, get_erase_color)
	else:
		if Input.is_action_pressed("draw"):
			draw_brush(mouse_position, get_brush_texture_pixel)
		if Input.is_action_pressed("erase"):
			draw_brush(mouse_position, get_erase_color)
		
func get_brush_texture_pixel(x, y):
	var brush_texture_x = (x/brush_size) * brush_image.get_width()
	var brush_texture_y = (y/brush_size) * brush_image.get_height()
	return brush_image.get_pixel(brush_texture_x, brush_texture_y)
	
func get_erase_color(_x, _y):
	return background_color

func draw_brush(brush_position: Vector2, pixel_getter: Callable):
	var proportion := Vector2(1, 1)
	if stretch_mode == StretchMode.STRETCH_KEEP_ASPECT:
		var min_axis_index := size.min_axis_index()
		proportion = image.get_size() / size[min_axis_index]
	
	
	for x in brush_size:
		for y in brush_size:
			var brush_pixel: Color = pixel_getter.call(x, y)
			if is_zero_approx(brush_pixel.a):
				continue
				
			@warning_ignore("integer_division")
			var pixel_position := brush_position * proportion + Vector2(x-brush_size/2, y - brush_size/2)
			pixel_position = pixel_position.clamp(Vector2i(), image.get_size() - Vector2i(1, 1))
			image.set_pixelv(pixel_position, brush_pixel)
	texture = ImageTexture.create_from_image(image)


func _on_mouse_entered() -> void:
	is_active = true


func _on_mouse_exited() -> void:
	is_active = false
