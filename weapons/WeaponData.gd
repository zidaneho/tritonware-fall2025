class_name WeaponData extends Resource

enum WeaponType {
	SWORD,
	GUN
}

@export var weapon_name : String = "Weapon"
@export var weapon_type : WeaponType = WeaponType.SWORD
@export var icon : Texture2D
@export var scene : PackedScene
