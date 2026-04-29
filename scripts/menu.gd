extends Control

@onready var start: Button = $VFlowContainer/Start
@onready var quit: Button = $VFlowContainer/Quit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect(_start_game.bind())
	quit.pressed.connect(_quit_game.bind())

	
func _start_game() -> void:
	SceneManager.goto_scene("res://scenes/stage1.tscn")
	
	
func _quit_game() -> void:
	get_tree().quit()
