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
#	"res://Objects/Projectiles/BallProjectile.tscn",
	"res://Objects/Projectiles/BasicProjectile.tscn",
	"res://Objects/Projectiles/ShotgunPellet.tscn",
	"res://Objects/Projectiles/UrchinProjectile.tscn"
]


var hit_noise_list = [
	"res://Sounds/Hit-01.ogg",
	"res://Sounds/Hit-02.ogg",
	"res://Sounds/Hit-03.ogg"
]

var pew_noise_list = [
	"res://Sounds/Pew-01.ogg",
	"res://Sounds/Pew-02.ogg",
	"res://Sounds/Pew-03.ogg"
]
