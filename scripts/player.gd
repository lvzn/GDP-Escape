extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	JUMP,
	HURT,
	ATTACK,
	DIE
}

var health
var stars
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var state: State = State.IDLE
var dead = false

@onready var sprite = $AnimatedSprite2D
@onready var health_label = $GUI/Health/Label
@onready var stars_label = $GUI/StarCounter/Label
@onready var hitbox: Area2D = $Hitbox
@onready var death_timer: Timer = $DeathTimer
@onready var walk_timer: Timer = $WalkTimer

func _ready() -> void:
	hitbox.monitorable = false
	health = PlayerVariables.health
	stars = PlayerVariables.stars
	state = State.IDLE
	
func _process(delta: float) -> void:
	health_label.text = str(PlayerVariables.health)
	stars_label.text = str(PlayerVariables.stars)
	health = PlayerVariables.health
	


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_input()
	_update_state()
	_update_state_logic(delta)
	move_and_slide()


# -------------------------
# CORE SYSTEMS
# -------------------------

func _apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_input():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		AudioManager.play_sound("jump")
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK

func _update_state():
	# Hurt check has highest priority
	if PlayerVariables.health <= 0:
		state = State.DIE
		return
	if state == State.HURT:
		return
	if PlayerVariables.health < health:
		state = State.HURT
		health = PlayerVariables.health
		return
	if state == State.ATTACK:
		return

	var direction := Input.get_axis("move_backward", "move_forward")

	if not is_on_floor():
		state = State.JUMP
	elif direction == 0:
		state = State.IDLE
	else:
		state = State.RUN


# -------------------------
# STATE LOGIC
# -------------------------

func _update_state_logic(delta):
	var direction := Input.get_axis("move_backward", "move_forward")
	hitbox.monitorable = false

	match state:
		State.IDLE:
			_idle_state()

		State.RUN:
			_run_state(direction)

		State.JUMP:
			_jump_state(direction)

		State.HURT:
			_hurt_state()
			
		State.ATTACK:
			_attack_state()
			
		State.DIE:
			_die_state()


# -------------------------
# INDIVIDUAL STATES
# -------------------------

func _idle_state():
	sprite.play("idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)


func _run_state(direction):
	sprite.play("walking")
	sprite.flip_h = direction < 0
	velocity.x = direction * SPEED


func _jump_state(direction):
	sprite.play("jump")

	if direction != 0:
		sprite.flip_h = direction < 0
		velocity.x = move_toward(velocity.x, direction * SPEED, 5)
	else:
		velocity.x = move_toward(velocity.x, 0, 5)


func _hurt_state():
	sprite.play("hurt")
	velocity.x = move_toward(velocity.x, 0, 7.5)


func _attack_state():
	var direction := Input.get_axis("move_backward", "move_forward")
	if direction > 0:
		hitbox.scale.x = 1
	elif direction < 0:
		hitbox.scale.x = -1
	z_index = 100
	velocity.x = move_toward(velocity.x, 0, 6)
	sprite.play("attack")
	if sprite.frame in [5,6,7] and sprite.animation == "attack":
		hitbox.monitorable = true
	else:
		hitbox.monitorable = false
	
func _die_state():
	collision_layer = 1
	if not dead:
		sprite.play("die")
	if dead and death_timer.is_stopped():
		get_tree().reload_current_scene()
		PlayerVariables.health = 100
		PlayerVariables.stars = 0
		state == State.IDLE
		death_timer.queue_free()

	
"""
func _physics_process(delta: float) -> void:
	# Add the gravity.

	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite.play("jump")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_backward", "move_forward")
	if direction > 0:
		sprite.flip_h = false
	elif direction < 0:
		sprite.flip_h = true

	if direction == 0 and is_on_floor():
		sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 5)
	elif direction and is_on_floor():
		velocity.x = direction * SPEED
		sprite.play("walking")
		
	elif direction and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 1)
		sprite.play("jump")
		if not (velocity.x * direction > 0):
			velocity.x = move_toward(velocity.x, 0, 6)
	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if PlayerVariables.health < health:
		sprite.play("hurt")

	move_and_slide()
"""


func _on_animated_sprite_2d_animation_finished() -> void:
	if state == State.DIE and sprite.animation == "die":
		dead = true
		death_timer.start()
	if state == State.HURT and sprite.animation == "hurt":
		state = State.IDLE
	if state == State.ATTACK and sprite.animation == "attack":
		
		state = State.IDLE
		z_index = 0


func _on_animated_sprite_2d_animation_changed() -> void:
	if not sprite:
		return
	if sprite.animation == "walking":
		AudioManager.play_sound("blop", randf_range(1.5, 2.5))
		walk_timer.start()
	else:
		walk_timer.stop()
	if sprite.animation == "attack":
		AudioManager.play_sound("knife")
	if sprite.animation == "hurt":
		AudioManager.play_sound("player_hit")
	if sprite.animation == "die":
		AudioManager.play_sound("player_death")


func _on_walk_timer_timeout() -> void:
	var pitch = randf_range(1.5, 2.5)
	AudioManager.play_sound("blop", pitch)
