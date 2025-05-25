extends CharacterBody2D


const SPEED = 150.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D


@onready var coyote_time: Timer = $coyote_time
@onready var jump_buffer_timer: Timer = $jump_buffer_timer

@export var buffer_time : float = 0.2
@export var coyote : float = 0.2

@export var jump_height : float = 100
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.6

@onready var jump_velocity : float =((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float =((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float =((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0


var can_jump : bool = true
var jump_buffer : bool = false

func _physics_process(delta: float) -> void:
	velocity.y += get_jump_gravity() * delta
	
	if not is_on_floor():
		
		animation_player.play("jump")

	if Input.is_action_just_pressed("ui_accept"):
		if can_jump:
			jump()
		else :
			jump_buffer = true
			jump_buffer_timer.start(buffer_time)
	
	if is_on_floor():
		can_jump = true
		coyote_time.stop()
		
		if jump_buffer:
			jump()
			jump_buffer = false
		
	else :
		if coyote_time.is_stopped():
			coyote_time.start(coyote)
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if direction > 0:
			sprite_2d.flip_h = true
		else:
			sprite_2d.flip_h = false
		velocity.x = direction * SPEED
		animation_player.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animation_player.play("idle")

	move_and_slide()


func jump():
	velocity.y = jump_velocity
	can_jump = false

func get_jump_gravity():
	if velocity.y > 0:
		return jump_gravity
	else :
		return fall_gravity


func _on_coyote_time_timeout() -> void:
	can_jump = false
	coyote_time.stop()


func _on_jump_buffer_timer_timeout() -> void:
	jump_buffer = false
