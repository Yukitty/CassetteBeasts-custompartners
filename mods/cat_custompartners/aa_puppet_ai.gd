extends "res://battle/ai/archangels/AAPuppetAI.gd"


func create_effigy() -> bool:
	# why isn't the current victim just passed as an argument??
	var candidates = []
	for f in battle.get_fighters():
		if f.team != fighter.team:
			candidates.push_back(f.get_characters()[0])
	if num_effigies_spawned >= candidates.size():
		return .create_effigy()
	var victim: CharacterNode = candidates[num_effigies_spawned]

	# Check for mimic partners when spawning effigys.
	if not victim.character.partner_id in EFFIGY_FORMS \
	and "mimic_partner_id" in victim.character \
	and victim.character.mimic_partner_id in EFFIGY_FORMS:
		var real_partner_id: String = victim.character.partner_id
		victim.character.partner_id = victim.character.mimic_partner_id
		var result: bool = .create_effigy()
		victim.character.partner_id = real_partner_id
		return result

	return .create_effigy()
