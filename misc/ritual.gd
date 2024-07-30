extends Node2D

@export var damage_amount: int = 2

@onready var area2d: Area2D = $Area2D

func deal_damage() -> void:
	print('Ritual is doing damage!')
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			enemy.take_damage(damage_amount)
