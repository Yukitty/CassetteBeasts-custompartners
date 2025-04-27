extends "res://global/save_state/Party.gd"


var cat_custompartners: Array


func start_new_file() -> void:
	.start_new_file()
	cat_custompartners.clear()


func get_snapshot() -> Dictionary:
	var snap: Dictionary = .get_snapshot()

	# Erase custom partner slot in favor of using a custom structure.
	# This also helps with removing the mod, because the vanilla game script errors when unknown partners are unlocked.
	snap.unlocked_partners.erase("cat_custompartner")
	snap.partners.erase("cat_custompartner")

	# Save all custom partner slots separately in their own section.
	var custom_partners_snap: Array = []
	for p in cat_custompartners:
		custom_partners_snap.append(p.get_snapshot())
	var section: Dictionary = {
		"save_slots": custom_partners_snap,
		"selected": cat_custompartners.find(partner),
	}
	snap.cat_custompartners = section
	return snap


func set_snapshot(snap: Dictionary, version: int) -> bool:
	if not .set_snapshot(snap, version):
		return false

	if "cat_custompartners" in snap:
		var section: Dictionary = snap.cat_custompartners
		cat_custompartners.clear()

		# Grab custom partner shared source
		var source: Character
		for p in source_partners:
			if p.partner_id == "cat_custompartner":
				source = p
				break
		assert(source)

		# Clone source for each custom partner, load them all into the cat_custompartners array
		var p: Character
		for data in section.save_slots:
			p = source.duplicate()
			if not p.set_snapshot(data, version):
				return false
			cat_custompartners.append(p)

		# Assume custom partner is unlocked if the save file has any.
		if not cat_custompartners.empty() and not "cat_custompartner" in unlocked_partners:
			unlocked_partners.push_back("cat_custompartner")

		# If one of the custom partners was the current partner in the save, copy that one into the active partners list.
		if current_partner_id == "cat_custompartner":
			var selected: int = int(section.selected)
			assert(selected >= 0 and selected < cat_custompartners.size())
			if selected < 0:
				selected = 0
			partners.erase(partner) # This is (or should be) the blank dummy from new game.
			partners.append(cat_custompartners[selected])
			set_current_partner_id(current_partner_id) # Reset party NPCs

	return true
