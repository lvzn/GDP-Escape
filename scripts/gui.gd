extends CanvasLayer

#@export var parallax_strength: float = 0.1
#@onready var label: Label = $Label
#@onready var camera: Camera2D = $Camera2D
#var initial_camera_pos: Vector2
#var initial_ui_pos: Vector2
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#initial_camera_pos = camera.get_screen_center_position()
	#initial_ui_pos = label.position
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#var current_camera_offset = camera.global_position - initial_camera_pos
	#var parallax_offset = -current_camera_offset * parallax_strength
	#label.position = initial_ui_pos + parallax_offset
	#
	#pass
