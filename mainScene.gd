extends Node3D





func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("ui_accept"):
		LoopManager.currentLoop += 1
		
