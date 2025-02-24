extends Node2D

@export var source: TextureRect
@export var target: TextureRect
@export var label: Label

func _on_button_pressed() -> void:
	var source_image := source.texture.get_image()
	var target_image := target.texture.get_image()
	var metrics := source_image.compute_image_metrics(target_image, false)
	label.text = str(metrics)
