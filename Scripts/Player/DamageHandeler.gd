extends Area3D

const I_TIME = 0.3
const MAX_HP = 150

var current_i_time = I_TIME
var invincible = false

var HP = MAX_HP

func _process(delta: float) -> void:
	## I-frames ##
	if invincible:
		current_i_time -= delta
		if current_i_time <= 0:
			invincible = false
			current_i_time = I_TIME

func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("projectile"):
		return
	
	HP -= body.damage
	invincible = true
	# TODO add hud interaction
	
	body.queue_free()
