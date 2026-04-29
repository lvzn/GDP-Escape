extends Node2D

const SPEED = 50

var direction = 1
var animation_finished = false
var player_in_area = false
var health

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var vision_right: RayCast2D = $VisionRight
@onready var vision_left: RayCast2D = $VisionLeft
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var spot_timer: Timer = $SpotTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var delay_timer: Timer = $DelayTimer
@onready var area_2d: Area2D = $AnimatedSprite2D/Hitbox

enum States{PATROL, COMBAT, SPOT, CHARGE, ATTACK, HURT, DIE}
var state = States.PATROL
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		States.PATROL: 
			animated_sprite_2d.play("walk")
			if not ray_cast_left.is_colliding():
				direction = 1
				animated_sprite_2d.flip_h = false
				area_2d.scale = Vector2(1,1)
			if not (ray_cast_right.is_colliding()):
				direction = -1
				animated_sprite_2d.flip_h = true
				area_2d.scale = Vector2(-1, 1)
			if (vision_left.is_colliding() and direction == -1):
				state = States.SPOT
			if (vision_right.is_colliding() and direction == 1):
				state = States.SPOT
			position.x += direction * SPEED * delta
		States.SPOT:
			animated_sprite_2d.play("idle")
			spot_timer.start()
			state = States.CHARGE
		States.CHARGE:
			if spot_timer.is_stopped():
				charge_timer.start()
				animated_sprite_2d.play("walk", 2)
				state = States.ATTACK
		States.ATTACK:
			if vision_left.is_colliding() or vision_right.is_colliding():
				var collision_point = (
					vision_left.get_collision_point().x if vision_left.is_colliding() 
					else vision_right.get_collision_point().x
					)
				var diff = global_position.x - collision_point
				if (abs(diff) < 70):
					animated_sprite_2d.play("attack")
					if animated_sprite_2d.frame in [6,7]:
						area_2d.monitoring = true
					else:
						area_2d.monitoring = false
					if animation_finished == true:
						state = States.PATROL
					animation_finished = false
				else:
					position.x += direction * SPEED * 2 * delta
			else:
				state = States.PATROL
		States.COMBAT:
			animated_sprite_2d.play("idle")
		States.HURT:
			if health <= 0:
				state = States.DIE
			animated_sprite_2d.play("hurt")
			if animation_finished == true:
				state = States.PATROL
			animation_finished = false
		States.DIE:
			animated_sprite_2d.play("death")
			
		_:
			state = States.PATROL
			
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "death":
		queue_free()
	animation_finished = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	PlayerVariables.health -= 25

func _on_hurtbox_area_entered(area: Area2D) -> void:
	health -= 50
	state = States.HURT
	AudioManager.play_sound("enemy_hit")


func _on_animated_sprite_2d_animation_changed() -> void:
	if not animated_sprite_2d:
		return
	if animated_sprite_2d.animation == "attack":
		delay_timer.start()
	if animated_sprite_2d.animation == "hurt":
		AudioManager.play_sound("enemy_hit")
	if animated_sprite_2d.animation == "death":
		AudioManager.play_sound("enemy_death")



func _on_delay_timer_timeout() -> void:
	if animated_sprite_2d.animation == "attack":
		AudioManager.play_sound("sword")
