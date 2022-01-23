extends Resource
class_name ProjectileProperties

export (int) var spread = 0

export (float) var lifetime = 1.0
export (float) var speed = 2000.0
export (float) var damage = 20.0

var instance_position := Vector2.ZERO
var instance_heading := Vector2.ZERO
var player_dun_shootin := true


enum Type {
#	BALL,
	BULLET,
	PELLET,
	URCHIN
}


# TODO fill preloads
var lookup = [
#	load("res://Objects/Projectiles/BallProjectile.tscn"),
	load("res://Objects/Projectiles/BasicProjectile.tscn"),
	load("res://Objects/Projectiles/ShotgunPellet.tscn"),
	load("res://Objects/Projectiles/UrchinProjectile.tscn")
]


var hit_noise_list = [
	load("res://Sounds/Hit-01.ogg"),
	load("res://Sounds/Hit-02.ogg"),
	load("res://Sounds/Hit-03.ogg")
]

var pew_noise_list = [
	load("res://Sounds/Pew-01.ogg"),
	load("res://Sounds/Pew-02.ogg"),
	load("res://Sounds/Pew-03.ogg")
]
