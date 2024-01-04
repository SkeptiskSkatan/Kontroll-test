extends CharacterBody3D



#spelar noder
@onready var node_3d = $Node3D

@onready var camera_3d = $Node3D/Camera3D

@onready var spelare = $"."

@onready var st_nde_m_nniska = $"StåndeMänniska"

@onready var hukande_m_nniska = $"HukandeMänniska"

@onready var ray_cast_3d = $RayCast3D

#hastighets variabler 
var nuvarandeFart = 5.0
const springa = 8.0
const gå = 5.0
const hukan = 3.0

const jump_velocity = 4.5



#varierande spelar information
const mouse_sens = 20

var ökning = 10.0

var direction = Vector3.ZERO

var hukanDjup = -0.5

var spelareHöjd = 1.8


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")





#mus och rörande av kamera 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		spelare.rotation_degrees.y += deg_to_rad(-event.relative.x * mouse_sens)
		camera_3d.rotation_degrees.x += deg_to_rad(-event.relative.y * mouse_sens)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89),deg_to_rad(89))


#Springa och gå och huka 

func _physics_process(delta):

	if Input.is_action_pressed("huka"):
		nuvarandeFart = hukan
		node_3d.position.y = lerp(node_3d.position.y,spelareHöjd + hukanDjup, delta*ökning)
		hukande_m_nniska.disabled=false
		st_nde_m_nniska.disabled=true
	elif !ray_cast_3d.is_colliding():
		
		hukande_m_nniska.disabled=true
		st_nde_m_nniska.disabled=false
		node_3d.position.y = lerp(node_3d.position.y,spelareHöjd, delta*ökning)
		if Input.is_action_pressed("spring"):
			nuvarandeFart = springa 
		else:
			nuvarandeFart = gå  
	
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta



	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity





	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("vänster", "högre", "fram", "bak")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*ökning)
	if direction:
		velocity.x = direction.x * nuvarandeFart
		velocity.z = direction.z * nuvarandeFart
	else:
		velocity.x = move_toward(velocity.x, 0, nuvarandeFart)
		velocity.z = move_toward(velocity.z, 0, nuvarandeFart)

	move_and_slide()
