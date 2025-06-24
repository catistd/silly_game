extends CharacterBody3D

### constants ###
# TODO make json config file to store these values

const I_TIME = 0.3
const MAX_HP = 150

@onready var HP_Guage = $CanvasLayer/UI/HUD/HP/HP_guage
@onready var HP_num = $CanvasLayer/UI/HUD/HP/HP_num
const HP_Guage_speed = 2

const SPEED = 100

const JUMP_VELOCITY = 6.0
const JUMP_BOOST = 1.2

const DASH_MULTIPLIER = 10
const DASH_DURATION = 0.2
const DASH_RECHARGE_MULTIPLIER = 10
const DASH_METER_MAX = 100
const DASH_COST = 50

@onready var neck := $neck
@onready var cam := $neck/Camera3D
const sens = .01

### traker variables ###

### double jump commented out for now 
	# TODO consult team about double jump
	# var double_jump = true

var dash_time = DASH_DURATION
var dashing = false
var dash_meter = DASH_METER_MAX

var current_i_time = I_TIME
var invincible = false

var HP = MAX_HP

## camera movement ##
func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sens)
			cam.rotate_x(-event.relative.y * sens)
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
	# else:
		# double_jump = true

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity.x *= JUMP_BOOST
		velocity.z *= JUMP_BOOST
	# if Input.is_action_just_pressed("jump") and not is_on_floor() and double_jump:
		# velocity.y = JUMP_VELOCITY
		# double_jump = false

	if Input.is_action_just_pressed("dash") and !dashing and dash_meter >= 50:
		dashing = true
		dash_meter -= DASH_COST

		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var dash_direction

		if input_dir:
			dash_direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		else:
			dash_direction = -neck.transform.basis.z.normalized()

		velocity = dash_direction * SPEED * DASH_MULTIPLIER

	## dash cooldown handeler ##
	if dashing and dash_time > 0:
		dash_time -= delta
	else:
		dashing = false
		dash_time = DASH_DURATION

	if dash_meter < DASH_METER_MAX:
		dash_meter += delta * DASH_RECHARGE_MULTIPLIER
	elif dash_meter > DASH_METER_MAX:
		dash_meter = DASH_METER_MAX

	## basic movment ##
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction and !dashing:
		velocity.x *= direction.x * SPEED
		velocity.z *= direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	### HP ###

	## I-frames ##
	if invincible:
		current_i_time -= delta
		if current_i_time <= 0:
			invincible = false
			current_i_time = I_TIME

	## UI ##
	var HP_Val_Wrapper = round(move_toward(HP_Guage.value, HP, delta * HP_Guage_speed))
	HP_Guage.value = HP_Val_Wrapper
	HP_num.text = str(HP_Val_Wrapper)

	move_and_slide()

func _on_hit_detector_body_entered(body: Node3D) -> void:
	if !body.is_in_group("projectile"):
		return
	
	HP -= body.damage
	invincible = true
	
	body.queue_free()
