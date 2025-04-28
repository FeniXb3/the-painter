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

var operation_history: Array[Command]
var latest_operation_index: int

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
	elif event.is_action_pressed("undo"):
		if abs(latest_operation_index) <= operation_history.size(): 
			var last_operation = operation_history[latest_operation_index]
			if last_operation != null:
				last_operation.undo()
				latest_operation_index -= 1
	elif event.is_action_pressed("redo"):
		if operation_history.is_empty() or latest_operation_index == -1:
			return
		
		latest_operation_index += 1
		var operation_to_redo = operation_history[latest_operation_index]
		if operation_to_redo == null:
			return
		
		operation_to_redo.execute()
		


func _process(_delta: float) -> void:
	var mouse_position: Vector2i = get_local_mouse_position()
	if not Rect2(Vector2(), size).has_point(mouse_position):
		return
		
	if Input.is_action_just_pressed("draw"):
		var draw_command = DrawBrushCommand.new(self, image, brush_size, mouse_position, get_brush_texture_pixel)
		if not operation_history.is_empty():
			operation_history.resize(operation_history.size() + latest_operation_index + 1)
		operation_history.append(draw_command)
		print(operation_history)
		latest_operation_index = -1
		draw_command.execute()
	if Input.is_action_pressed("erase"):
		var draw_command = DrawBrushCommand.new(self, image, brush_size, mouse_position, get_erase_color)
		if not operation_history.is_empty():
			operation_history.resize(operation_history.size() + latest_operation_index + 1)
		operation_history.append(draw_command)
		print(operation_history)
		latest_operation_index = -1
		draw_command.execute()
		
func get_brush_texture_pixel(x, y):
	var brush_texture_x = (x/brush_size) * brush_image.get_width()
	var brush_texture_y = (y/brush_size) * brush_image.get_height()
	return brush_image.get_pixel(brush_texture_x, brush_texture_y)
	
func get_erase_color(_x, _y):
	return background_color


func _on_mouse_entered() -> void:
	is_active = true


func _on_mouse_exited() -> void:
	is_active = false
