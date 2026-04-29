extends Area2D

func _on_body_entered(_body: Node2D) -> void:
	print("star +1")
	PlayerVariables.stars += 1
	AudioManager.play_sound("star")
	queue_free()
