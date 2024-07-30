extends Node

@export var speed: float = 1

var enemy: Enemy
var sprite: AnimatedSprite2D

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta: float) -> void:
	var player_position = GameManager.player_position
	var direction_vector = player_position - enemy.position
	var input_vector = direction_vector.normalized()
	enemy.velocity = input_vector * speed * 100
	handle_sprite_orientation(input_vector)
	enemy.move_and_slide()
	
func handle_sprite_orientation(input_vector: Vector2) -> void:
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
