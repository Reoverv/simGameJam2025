extends Node


var currentLoop: int :
	set (value):
		currentLoop = value
		updateLoop()
		nextLoop.emit()

		
var puzzleObjects: Array[PuzzleObject] 

signal nextLoop


func updateLoop():
	for obj in puzzleObjects:
		obj.currentLoop += 1
