class_name DrawBrushCommand
extends Command

var target: TextureRect
var image: Image
var brush_size: float
var brush_position: Vector2
var pixel_getter: Callable

var before_pixels: Dictionary[Vector2, Color]


func _init(target: TextureRect, image: Image, brush_size: float, brush_position: Vector2, pixel_getter: Callable) -> void:
	self.target = target
	self.image = image
	self.brush_size = brush_size
	self.brush_position = brush_position
	self.pixel_getter = pixel_getter
	
	self.before_pixels = {}

func execute():
	draw_brush(brush_position, pixel_getter)
	
func undo():
	draw_brush(brush_position, get_before_pixel)

func get_before_pixel(x, y):
	return before_pixels.get(Vector2(x, y), Color.TRANSPARENT)

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
			
			if not before_pixels.has(Vector2(x, y)):
				before_pixels[Vector2(x, y)] = image.get_pixelv(pixel_position)
			image.set_pixelv(pixel_position, color_to_set)
	target.texture = ImageTexture.create_from_image(image)
