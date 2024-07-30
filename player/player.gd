class_name Player
extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 3
@export_category("Damage")
@export var base_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene
@export_category("HP")
@export var current_health: int = 100
@export var max_health: int = 100
@export var death_prefab: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var hitbox_area: Area2D = $HitboxArea

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0

func _process(delta: float) -> void:
	update_player_position()
	read_input()
	update_attack_cooldown(delta)
	play_animation()
	handle_sprite_orientation()
	handle_attack()
	hitbox_detection(delta)
	update_ritual(delta)

func _physics_process(delta: float) -> void:
	move_player()


func update_player_position() -> void:
	GameManager.player_position = position

func read_input() -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	was_running = is_running
	is_running = not input_vector.is_zero_approx()
	handle_joystick_deadzone()

func handle_joystick_deadzone() -> void:
	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0

func move_player() -> void:
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.05)
	move_and_slide()

func play_animation() -> void:
	if not is_attacking and was_running != is_running:
		if is_running:
			animation_player.play("run")
		else:
			animation_player.play("idle")

func handle_sprite_orientation() -> void:
	if not is_attacking:
		if input_vector.x > 0:
			sprite.flip_h = false
		elif input_vector.x < 0:
			sprite.flip_h = true

func update_attack_cooldown(delta: float) -> void:
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func handle_attack() -> void:
	if Input.is_action_just_pressed("attack"):
		if is_attacking:
			return
		animation_player.play("attack_side_1")
		attack_cooldown = 0.6
		is_attacking = true

func deal_damage() -> void:
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >= 0.3:
				enemy.take_damage(base_damage)
				
func hitbox_detection(delta: float) -> void:
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0:
		return
	
	hitbox_cooldown = 0.5
	
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var enemy_damage = 1
			take_damage(enemy_damage)
			
func update_ritual(delta: float) -> void:
	ritual_cooldown -= delta
	if ritual_cooldown > 0:
		return
	ritual_cooldown = ritual_interval
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return
	
	current_health -= amount
	print('==> PLAYER Took ', amount, ' damage. Remaining health ', current_health)
	if current_health <= 0:
		die()
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
		
func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()

func heal(amount: int) -> int:
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	print("PLAYER healed! current health = ", current_health)
	return current_health
	

