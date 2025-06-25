extends Node3D
class_name GunBase

### weapon info ###

enum FireType {Main, Alt}
enum Stat {Proj, Vel, Amo, Dmg}

@export var Name: String
@export var AmmoCapacity: int

## references to nodes in the weapon scene
@export var BarrelEnd: Marker3D
@export var model: Node3D # TODO this will be used to trigger the animations during weapon actions, 
# as no animations currently exist it is unused

@export_category("Main Fire")
@export var projectile: PackedScene
@export var projectile_velocity: float
@export var fire_rate: int
@export var ammo_use: int
@export var damage: int

@export_category("Alt Fire")
@export var alt_enabled: bool
@export var alt_projectile: PackedScene
@export var alt_projectile_velocity: float
@export var alt_fire_rate: int
@export var alt_ammo_use: int
@export var alt_damage: int

var MainStat
var AltStat

### Tracker Variables ###

var CurrentAmmo = AmmoCapacity

func _ready() -> void:
	## sanity checks
	var error_base = "gun:" + name + "at" + str(self.get_path())
	if BarrelEnd == null:
		push_error(error_base + " : no specified barrel")
	if projectile == null:
		push_error(error_base + " : no main projectile")
	if alt_projectile == null && alt_enabled:
		push_error(error_base + " : alt fire enabled but no alternate projectile provided")

	## setup fire mode stats
	MainStat = {Stat.Proj : projectile, Stat.Vel : projectile_velocity, 
				Stat.Amo : ammo_use, Stat.Dmg : damage}
	AltStat = {Stat.Proj : alt_projectile, Stat.Vel : alt_projectile_velocity,
			   Stat.Amo : alt_ammo_use, Stat.Dmg : alt_damage}

## DO NOT RUN WHEN GUN IS NOT CHILD OF PLAYER
func fire(end_pos: Vector3, type: FireType):
	if CurrentAmmo <= 0:
		# TODO add no ammo notification / maybe auto reload
		return

	var Stats
	match type:
		FireType.Main: Stats = MainStat
		FireType.Alt: 
			Stats = AltStat
			if !alt_enabled:
				return

	# TODO add fire animations here
	# TODO recoil
	# TODO muzzle flash

	var start_pos = BarrelEnd.position

	CurrentAmmo -= Stats[Stat.Amo]

	var fire_dir = (end_pos - start_pos).normalized()
	var proj = Stats[Stat.Proj].instantiate()

	proj.position = start_pos
	proj.linear_velocity = fire_dir * Stats[Stat.Vel]
	proj.damage = Stats[Stat.Dmg]
	get_parent().add_sibling(proj)

func reload():
	# TODO play animation here after they're made
	CurrentAmmo = AmmoCapacity
