extends Node2D


var sound = {
	"star": preload("res://assets/sfx/star.wav"),
	"knife": preload("res://assets/sfx/knife.wav"),
	"block": preload("res://assets/sfx/block.wav"),
	"enemy_death": preload("res://assets/sfx/enemy_death.wav"),
	"enemy_hit": preload("res://assets/sfx/enemy_hit.wav"),
	"blop": preload("res://assets/sfx/blop.ogg"),
	"jump": preload("res://assets/sfx/jump.wav"),
	"player_death": preload("res://assets/sfx/player_death.wav"),
	"player_hit": preload("res://assets/sfx/player_hit.wav"),
	"sword": preload("res://assets/sfx/sword_swing.wav")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func play_sound(name: String, pitch: float = 1.0) -> void:
	var player = AudioStreamPlayer.new()
	player.finished.connect(_on_player_finished.bind(player))
	add_child(player)
	player.bus = "SFX"
	player.stream = sound[name]
	player.pitch_scale = pitch
	player.play()
	
	
func _on_player_finished(player: AudioStreamPlayer):
	player.stream = null
	player.queue_free()
