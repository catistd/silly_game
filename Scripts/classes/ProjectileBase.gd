extends RigidBody3D
class_name ProjectileBase

@export_category("Bullet Stats")
@export var damage: int
@export var lifetime: float
@export var persistant: bool

var destroy = Callable(self, "Kill")

func _ready() -> void:
	self.add_to_group("projectile")

	if !persistant:
		self.body_entered.connect(destroy)

	# manage projectile lifetime 
	var timer := Timer.new()
	add_child(timer)

	timer.wait_time = lifetime
	timer.one_shot = true

	timer.timeout.connect(destroy)

	timer.start()

func Kill() -> void:
	queue_free()
