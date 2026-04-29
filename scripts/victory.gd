extends Control

@onready var quit: Button = $VFlowContainer/Quit
@onready var highscore_label: Label = $VFlowContainer/HighscoreLabel
@onready var score_label: Label = $VFlowContainer/ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	highscore_label.text = "Highscore: " + str(PlayerVariables.highscore)
	if PlayerVariables.stars > PlayerVariables.highscore:
		highscore_label.text = "(new!) Highscore: " + str(PlayerVariables.stars)
		PlayerVariables.save_score()
	score_label.text = "Your score: " + str(PlayerVariables.stars)
	quit.pressed.connect(_quit_game.bind())


	
func _quit_game() -> void:
	get_tree().quit()
