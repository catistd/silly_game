extends Node3D
class_name GunBase

enum FireType {Main, Alt}
enum Stat {Proj, Vel}

@export_category("Main Fire")
@export var projectile: PackedScene
@export var projectile_velocity: int
@export var fire_rate: int

@export_category("Alt Fire")
@export var enabled: bool
@export var alt_projectile: PackedScene
@export var alt_projectile_velocity: int
@export var alt_fire_rate: int

var MainStat
var AltStat

func _ready() -> void:
	MainStat = {Stat.Proj : alt_projectile, Stat.Vel : alt_projectile_velocity}
	AltStat = {Stat.Proj : projectile, Stat.Vel : projectile_velocity}

## DO NOT RUN WHEN GUN IS NOT CHILD OF PLAYER
func fire(start_pos: Vector3, end_pos: Vector3, type: FireType):
	var Stats
	match type:
		FireType.Main: Stats = MainStat
		FireType.Alt: Stats = AltStat

	var fire_dir = (end_pos - start_pos).normalized()
	var proj = Stats[Stat.Proj].instantiate()

	proj.position = start_pos
	proj.velocity = fire_dir * Stats[Stat.Vel]
	get_parent().add_sibling(proj)
