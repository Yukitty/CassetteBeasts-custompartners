extends "res://global/save_state/Party.gd"


var cat_custompartners: Array


func start_new_file() -> void:
	.start_new_file()
	cat_custompartners.clear()


func setup(rand: Random) -> void:
	# Add custom partner source
	var source_partner: Character = load("res://mods/cat_custompartners/custom_partner.tres")
	source_partners.append(source_partner)
	initial_partner_levels[source_partner.partner_id] = 10

	.setup(rand)

	# "Test World" custom partner setup
	var partner: Character
	for p in partners:
		if p.partner_id == source_partner.partner_id:
			partner = p
			break
	assert(partner)
	if not partner:
		return
	partner.name = tr(partner.name)
	var template = HumanLayersHelper.randomize_sprite(rand, partner.human_part_names, partner.human_colors)
	partner.pronouns = template.pronouns
	var mimic_partners: Array = unlocked_partners.duplicate()
	mimic_partners.erase(partner.partner_id)
	partner.mimic_partner_id = rand.choice(mimic_partners)
	set_current_partner_id(partner.partner_id)


func get_snapshot() -> Dictionary:
	var snap: Dictionary = .get_snapshot()

	# Erase custom partner slot in favor of using a custom structure.
	# This also helps with removing the mod, because the vanilla game script errors when unknown partners are unlocked.
	snap.unlocked_partners.erase("cat_custompartner")
	if current_partner_id != "cat_custompartner": # This check is for the "Test World" dev file
		snap.partners.erase("cat_custompartner")
	if cat_custompartners.empty():
		return snap # Don't write ANY custom data if no custom partners have been created.

	# Save all custom partner slots separately in their own section.
	snap.partners.erase("cat_custompartner")
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

	# Assume custom partner is unlocked if the save file has any.
	if (not cat_custompartners.empty() or current_partner_id == "cat_custompartner") \
	and not "cat_custompartner" in unlocked_partners:
		unlocked_partners.push_back("cat_custompartner")

	var section: Dictionary
	if "cat_custompartners" in snap: # Custom partner data in party
		section = snap.cat_custompartners
	else: # No custom partner data.
		return true

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

	# If one of the custom partners was the current partner in the save, copy that one into the active partners list.
	if current_partner_id == "cat_custompartner" and not cat_custompartners.empty():
		var selected: int = int(section.selected)
		assert(selected >= 0 and selected < cat_custompartners.size())
		if selected < 0:
			selected = 0
		partners.erase(partner) # This is (or should be) the blank dummy from new game.
		partners.append(cat_custompartners[selected])
		set_current_partner_id(current_partner_id) # Reset party NPCs

	return true


func is_ready_for_relationship_level_up(c: Character) -> bool:
	if c.partner_id == "cat_custompartner" and c.relationship_level >= Character.REL_LEVEL_MAX:
		return false # You cannot romance the custom partners. Sorry.
	return .is_ready_for_relationship_level_up(c)
