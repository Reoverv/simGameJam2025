class_name Player extends CharacterBody3D



@export_category("Player Settings")
@export var Move_Speed : float = 1.5
@export var Sprint_Speed : float = 10.0


@export_category("Inputs")
@export var InputDictionary : Dictionary = {
	"Forward": "forward",
	"Backward": "down",
	"Left": "left",
	"Right": "right",
	"Jump": "jump",
	"Escape": "escape",
	"Sprint": "sprint",
	"Interact": "interact"
}

@export_category("Mouse Settings")
@export_range(0.09, 0.1) var Mouse_Sens : float = 0.09
@export_range(1.0, 50.0) var Mouse_Smooth : float = 50.0


# Onready


@onready var head: Node3D = $Head
@onready var camera : Camera3D = $Head/Camera3D
@onready var rayCast: RayCast3D = $Head/PlayerInetractcast
@onready var pickup_point: Marker3D = $Head/pickupPoint


# Vectors
var direction : Vector3 = Vector3.ZERO
var Camera_Inp : Vector2 = Vector2()
var Rot_Vel : Vector2 = Vector2()


var _speed : float = Move_Speed
var _isMouseCaptured : bool = true
var pickedUpObject: PuzzleObject

const JUMP_VELOCITY : float = 4.5

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Camera_Inp = event.relative
	if Input.is_action_just_pressed("interact"):
		interact()

func _process(delta: float) -> void:
	# Camera Lock
	if Input.is_action_just_pressed(InputDictionary["Escape"]) and _isMouseCaptured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_isMouseCaptured = false
	elif Input.is_action_just_pressed(InputDictionary["Escape"]) and not _isMouseCaptured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_isMouseCaptured = true

	# Camera Smooth look
	Rot_Vel = Rot_Vel.lerp(Camera_Inp * Mouse_Sens, delta * Mouse_Smooth)
	head.rotate_x(-deg_to_rad(Rot_Vel.y))
	rotate_y(-deg_to_rad(Rot_Vel.x))
	head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
	Camera_Inp = Vector2.ZERO

	
func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(InputDictionary["Jump"]) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#	Modified standard input for smooth movements.
	var input_dir : Vector2 = Input.get_vector(InputDictionary["Left"], InputDictionary["Right"], InputDictionary["Forward"], InputDictionary["Backward"])
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized(), delta * 7.0)
	_speed = lerp(_speed, Move_Speed, min(delta * 5.0, 1.0))
	Sprint()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x,0,_speed)
		velocity.z = move_toward(velocity.z,0,_speed)
	
	
	handPickedObject()
	
	
	move_and_slide()

func interact():
	if pickedUpObject != null:
		pickedUpObject.freeze = false
		rayCast.set_collision_mask_value(2, true)
		pickedUpObject = null
		return
	
	pickedUpObject = rayCast.get_collider() as PuzzleObject
	if pickedUpObject == null:
		return
	pickup_point.global_transform = pickedUpObject.global_transform
	rayCast.set_collision_mask_value(2, false)


func handPickedObject():
	if pickedUpObject == null:
		return
		
	var target_pos: Vector3

	# CRITICAL FIX: Check if the ray is colliding
	if rayCast.is_colliding():
		
		var collision_point = rayCast.get_collision_point()
		var collision_normal = rayCast.get_collision_normal()
		target_pos = collision_point + collision_normal * 0.5
	else:
		# If it hits nothing (sky), the target is the end of the ray
		target_pos = rayCast.to_global(rayCast.target_position)
	
	var pos: Vector3 = rayCast.to_global(rayCast.target_position)
	var posNorm:Vector3 =  rayCast.get_collision_normal()
	
	pickedUpObject.global_position = pickedUpObject.global_position.lerp(target_pos, 0.05)
	pickedUpObject.sleeping = true
	
	
	
func Sprint() -> void:
	if Input.is_action_pressed(InputDictionary["Sprint"]):
		_speed = lerp(_speed, Sprint_Speed, 0.1)
	else:
		_speed = lerp(_speed, Move_Speed, 0.1)
