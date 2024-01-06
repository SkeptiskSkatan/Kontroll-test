extends CharacterBody3D



#spelar noder

@onready var ögon = $"nalke/Node3D/ögon"


@onready var nalke = $nalke

@onready var node_3d = $nalke/Node3D

@onready var camera_3d = $"nalke/Node3D/ögon/Camera3D"

@onready var spelare = $"."

@onready var st_nde_m_nniska = $"StåndeMänniska"

@onready var hukande_m_nniska = $"HukandeMänniska"

@onready var ray_cast_3d = $RayCast3D

@onready var animation_player = $"nalke/Node3D/ögon/AnimationPlayer"

#hastighets variabler 
var nuvarandeFart = 5.0
const springa = 8.0
const gå = 5.0
const hukan = 3.0
var glidVector = Vector2.ZERO
var glidFart = 10.0

const jump_velocity = 4.5


# Tillstånd

var gående = false
var spring = false 
var hukaSig = false 
var tittaFri = false
var glidning = false



#glida 

var glidTid = 0.0
var glidTidMax = 1.0



# huvud skakning 

const huvudSkakningSpringFart = 22.0
const huvudSkakningGåFart = 14.0
const headSkakningHukaFart = 10.0

const huvudSkakningSpringIntesnitet = 0.2
const huvudSkakningGåIntensitet = 0.1
const headSkakningHukaIntensitet = 0.05

var huvudSkakningVektor = Vector2.ZERO
var huvudSkakningIndex = 0.0
var huvudSkakningNu = 0.0





#varierande spelar information
const mouse_sens = 20

var ökning = 10.0

var luftLerp = 3

var direction = Vector3.ZERO

var hukanDjup = -0.5

var nakeLutningFri = 5



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")





#mus och rörande av kamera 

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		if tittaFri:
			nalke.rotation_degrees.y += deg_to_rad(-event.relative.x * mouse_sens)
			nalke.rotation.y = clamp(nalke.rotation.y, deg_to_rad(-120),deg_to_rad(120))
		else:
			spelare.rotation_degrees.y += deg_to_rad(-event.relative.x * mouse_sens)
		camera_3d.rotation_degrees.x += deg_to_rad(-event.relative.y * mouse_sens)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-89),deg_to_rad(89))


#Springa och gå och huka 

func _physics_process(delta):
	
	var input_dir = Input.get_vector("vänster", "högre", "fram", "bak")
	
	
	
	if Input.is_action_pressed("huka") || glidning:
		nuvarandeFart = lerp(nuvarandeFart,hukan, delta * ökning)
		node_3d.position.y = lerp(node_3d.position.y, hukanDjup, delta*ökning)
		hukande_m_nniska.disabled=false
		st_nde_m_nniska.disabled=true
		
		if spring && input_dir != Vector2.ZERO: 
			glidning = true
			glidTid = glidTidMax
			glidVector = input_dir
			tittaFri = true
			
			print("glid börjar")
			
			
		gående = false
		spring = false
		hukaSig = true
		
		
	elif !ray_cast_3d.is_colliding():
		
		
		#man står upp
		hukande_m_nniska.disabled=true
		st_nde_m_nniska.disabled=false
		node_3d.position.y = lerp(node_3d.position.y,0.0, delta*ökning)
		if Input.is_action_pressed("spring"):
			
			nuvarandeFart =lerp(nuvarandeFart,springa, delta * ökning)
			
			
			
			
			gående = false
			spring = true
			hukaSig = false
			
			
			
		else:
			nuvarandeFart = lerp(nuvarandeFart,gå, delta * ökning)
			
			gående = true
			spring = false 
			hukaSig = false
	
	#tittafritt kontroll
	
	if Input.is_action_pressed("fri") || glidning:
		
		tittaFri = true
		
		
		if glidning:
			
			camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(7.0), delta * ökning)
			
			
		else:
			
			
			camera_3d.rotation.z = -deg_to_rad(nalke.rotation.y * nakeLutningFri)
			
			
		
		
		
		
	else:
		
		tittaFri= false
		
		nalke.rotation.y = lerp(nalke.rotation.y,0.0,delta*ökning)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,0.0,delta*ökning)
	
	#Hanter glidning
	
	
	if glidning:
		
		glidTid-= delta
		if glidTid <=0:
			glidning=false
			tittaFri = false
			print("glid slutar")
		
	
	
	# hanter huvud skakning 
	
	if spring: 
		
		huvudSkakningNu = huvudSkakningSpringIntesnitet
		huvudSkakningIndex += huvudSkakningSpringIntesnitet
	elif gå:
		
		huvudSkakningNu = huvudSkakningGåIntensitet
		huvudSkakningIndex += huvudSkakningGåIntensitet 
	elif hukaSig:
		
		huvudSkakningNu = headSkakningHukaIntensitet
		huvudSkakningIndex += headSkakningHukaIntensitet
	
	if is_on_floor() && !glidning  && input_dir != Vector2.ZERO:
		huvudSkakningVektor.y =  sin(huvudSkakningIndex)
		huvudSkakningVektor.x =  sin(huvudSkakningIndex/2) + 0.5
		
		ögon.position.y = lerp(ögon.position.y, huvudSkakningVektor.y * (huvudSkakningNu/2.0),delta*ökning)
		ögon.position.x = lerp(ögon.position.x, huvudSkakningVektor.x * huvudSkakningNu,delta*ökning)
		
	else:
		
		ögon.position.y = lerp(ögon.position.y,0.0,delta*ökning)
		ögon.position.x = lerp(ögon.position.x, 0.0,delta*ökning)
		
		
	
	
	
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta



	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
		glidning = false
		
		animation_player.play("Hoppa")
		


	if is_on_floor():
		
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*ökning)
		
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*luftLerp)



	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	
	
	if glidning:
		direction = (transform.basis *  Vector3(glidVector.x,0,glidVector.y)).normalized()
		nuvarandeFart = (glidTid + 0.1) * glidFart
		
		
		
		
	
	
	if direction:
		velocity.x = direction.x * nuvarandeFart
		velocity.z = direction.z * nuvarandeFart
		
		

		
		
	else:
		velocity.x = move_toward(velocity.x, 0, nuvarandeFart)
		velocity.z = move_toward(velocity.z, 0, nuvarandeFart)

	move_and_slide()
