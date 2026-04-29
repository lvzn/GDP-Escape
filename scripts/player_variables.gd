extends Node2D


var health
var stars
var distance_traveled
var highscore
var save_path = "user://score.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 100
	stars = 0
	distance_traveled = 0
	highscore = load_score()
	

func save_score():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(stars)
	file.close()
	
	
func load_score():
	var score = 0
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		score = file.get_var()
	return score 
