class_name PuzzleObject
extends Node3D


@export var lifeTime: int = 0
@export var startingPos: Transform3D


var currentLoop: int
var isPickedUp: bool
var pickupPoint: Transform3D


func _ready() -> void:
	setStartingPos()
	LoopManager.nextLoop.connect(updateLoop)
	LoopManager.puzzleObjects.append(self)
	
	print(startingPos)
	
func setStartingPos():
	startingPos = self.global_transform
	

func pickedUp():
	isPickedUp = true

func _physics_process(delta: float) -> void:
	if isPickedUp:
		global_transform = pickupPoint

func updateLoop():
	self.global_position.x += 1
	print(currentLoop)
	print(lifeTime)
	if currentLoop == lifeTime:
		self.global_transform = startingPos
		currentLoop = 0
