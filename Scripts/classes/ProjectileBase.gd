extends RigidBody3D
class_name ProjectileBase

@export_category("Bullet Stats")
@export var damage: int
@export var lifetime: float
@export var persistant: bool

func _ready() -> void:
    self.add_to_group("projectile")

    var timer := Timer.new()
    add_child(timer)

    timer.wait_time = lifetime
    timer.one_shot = true

    timer.timeout.connect(Callable(self, "LifetimeEnd"))

    timer.start()


func LifetimeEnd() -> void:
    queue_free()