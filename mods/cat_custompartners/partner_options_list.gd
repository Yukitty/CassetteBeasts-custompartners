extends "res://nodes/menus/ArrowOptionList.gd"


func _ready() -> void:
	for i in SaveState.party.partners.size():
		var partner: Character = SaveState.party.partners[i]
		if partner.partner_id != "cat_custompartner" and partner.is_fusion_unlocked():
			values.append(partner.partner_id)
			value_labels.append(partner.name)
	set_selected_index(selected_index)
	adjust_min_size()
