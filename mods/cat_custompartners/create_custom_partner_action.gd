extends Action


const PARTNER_ID: String = "cat_custompartner"


func _run():
	var pawn: Spatial = get_pawn()
	var old_partner: Character = SaveState.party.partner
	var partner: Character = SaveState.party.get_partner_by_id(PARTNER_ID)

	# Set the mimic data
	if "mimic_partner_id" in blackboard and "mimic_partner_id" in partner:
		partner.mimic_partner_id = blackboard.mimic_partner_id

	if old_partner:
		SaveState.party.heal_character(old_partner)
	if partner:
		SaveState.party.heal_character(partner)

	# Unlock if needed, match level otherwise
	SaveState.party.unlock_partner(PARTNER_ID)
	partner.level = SaveState.party.player.level

	# Start with fusion unlocked.
	partner.relationship_level = Character.REL_LEVEL_FUSION

	# Give the selected starter tape
	if "starter_tape" in blackboard:
		SaveState.party.remove_tape(blackboard.starter_tape)
		partner.tapes = [blackboard.starter_tape]

	# Save partner to the special area (multiple custom partner save slots)
	assert("cat_custompartners" in SaveState.party)
	if "cat_custompartners" in SaveState.party:
		SaveState.party.cat_custompartners.append(partner)

	# Fade out
	var transition: bool = not SceneManager.transitioned_out
	if transition:
		SceneManager.transition = SceneManager.TransitionKind.TRANSITION_FADE
		yield (SceneManager.transition_out(), "completed")

	# Swap partners
	for tape in partner.tapes:
		SaveState.species_collection.register(tape)

	SaveState.party.current_partner_id = PARTNER_ID
	detach_root()

	get_tree().call_group("partner", "set_character", SaveState.party.partner)
	get_tree().call_group("partner", "set_global_translation", pawn.global_translation)
	get_tree().call_group("partner", "set_initial_direction", "down")

	pawn.get_parent().remove_child(pawn)
	pawn.queue_free()

	# Fade in
	if transition:
		yield (SceneManager.transition_in(), "completed")
	return true
