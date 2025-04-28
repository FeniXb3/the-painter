class_name DrawBrushCommand
extends Command

var target: TextureRect
var image: Image
var brush_size: float
var brush_position: Vector2
var pixel_getter: Callable

var previous_pixels: Dictionary[Vector2, Color]

func _init(p_target: TextureRect, p_image: Image, p_brush_size: float, p_brush_position: Vector2, p_pixel_getter: Callable) -> void:
	target = p_target
	image = p_image
	brush_size = p_brush_size
	brush_position = p_brush_position
	pixel_getter = p_pixel_getter

func execute():
	draw_brush(brush_position, pixel_getter)
	
func undo():
	draw_brush(brush_position, get_previous_pixel)
	
func get_previous_pixel(x, y):
	return previous_pixels.get(Vector2(x, y), Color.TRANSPARENT)

func draw_brush(brush_position: Vector2, pixel_getter: Callable):
	var proportion := Vector2(1, 1)
	if target.stretch_mode == TextureRect.StretchMode.STRETCH_KEEP_ASPECT:
		var min_axis_index := target.size.min_axis_index()
		proportion = image.get_size() / target.size[min_axis_index]
	
	
	for x in brush_size:
		for y in brush_size:
			var brush_pixel: Color = pixel_getter.call(x, y)
			if is_zero_approx(brush_pixel.a):
				continue
				
			@warning_ignore("integer_division")
			var pixel_position := brush_position * proportion + Vector2(x-brush_size/2, y - brush_size/2)
			pixel_position = pixel_position.clamp(Vector2i(), image.get_size() - Vector2i(1, 1))
			
			var current_pixel_color := image.get_pixelv(pixel_position)
			var color_to_set := Color(lerp(current_pixel_color, brush_pixel, brush_pixel.a), 1)
			
			previous_pixels[Vector2(x, y)] = current_pixel_color
			image.set_pixelv(pixel_position, color_to_set)
	target.texture = ImageTexture.create_from_image(image)
