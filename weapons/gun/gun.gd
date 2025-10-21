class_name Gun extends Node2D





@export var gun_name : String = "Gun"
@export var damage : int = 0
@export var fire_rate : float = 1.0
@export var mag_size : int = 10
@export var reload_time : float = 1.0
@export var spread : float = 0
@export var recoil : Vector2 = Vector2(0,0)
@export var range: float = 50
@export var bullet_color : Color


var current_ammo = mag_size

enum GunState {
	IDLE,
	SHOOTING,
	RELOADING,
}
var state : GunState = GunState.IDLE

enum ProjectileType {
	PROJECTILE,
}
var projectile_type : ProjectileType = ProjectileType.PROJECTILE

func shoot():
	pass
func reload():
	pass
func onEquip():
	pass
func onUnequip():
	pass
