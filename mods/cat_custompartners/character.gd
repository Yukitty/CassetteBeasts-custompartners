extends "res://data/Character.gd"


export var mimic_partner_id: String = "kayleigh"
export var allow_adjust_base_stats: bool = true


func set_snapshot(snap, version: int) -> bool:
	if not .set_snapshot(snap, version):
		return false
	if "cat_custompartners" in snap:
		mimic_partner_id = snap.cat_custompartners.mimic_partner_id
	return true


func get_snapshot() -> Dictionary:
	var snap: Dictionary = .get_snapshot()
	snap.cat_custompartners = {
		"mimic_partner_id": mimic_partner_id,
	}
	return snap
