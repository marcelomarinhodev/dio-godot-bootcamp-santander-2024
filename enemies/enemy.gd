class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene

func take_damage(amount: int) -> void:
	health -= amount
	print('Took ', amount, ' damage. Remaining health ', health)
	if health <= 0:
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
