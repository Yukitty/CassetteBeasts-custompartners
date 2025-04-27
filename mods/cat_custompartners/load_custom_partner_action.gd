extends Action


const LOAD_PARTNER_MENU: PackedScene = preload("res://mods/cat_custompartners/load_partner_menu.tscn")
const PARTNER_ID: String = "cat_custompartner"


var selection: int


func _run() -> bool:
	# Fail if there are no partners to load.
	assert("cat_custompartners" in SaveState.party)
	if not "cat_custompartners" in SaveState.party:
		return false
	if SaveState.party.cat_custompartners.empty():
		return false

	var pawn: Spatial = get_pawn()
	var old_partner: Character = SaveState.party.partner
	var partner: Character

	selection = -1
	yield (show_partner_file_menu(), "completed")

	if selection < 0: # Cancelled
		return true # Succeed without loading anything or changing partners

	# Remove old custom partner
	# Load new custom partner into party
	assert(selection >= 0 and selection < SaveState.party.cat_custompartners.size())
	partner = SaveState.party.cat_custompartners[selection]
	SaveState.party.partners.erase(SaveState.party.get_partner_by_id(PARTNER_ID))
	SaveState.party.partners.append(partner)

	# Move selected custom partner to the top of the list.
	SaveState.party.cat_custompartners.erase(partner)
	SaveState.party.cat_custompartners.push_front(partner)

	if old_partner:
		SaveState.party.heal_character(old_partner)
	if partner:
		SaveState.party.heal_character(partner)

	# Unlock if needed, but don't call unlock partner because that would reset it...
	if not PARTNER_ID in SaveState.party.unlocked_partners:
		SaveState.party.unlocked_partners.append(PARTNER_ID)
	# TODO: Figure out how to calculate background levels instead,
	# considering the partner doesn't stay active...
	if partner.level < SaveState.party.player.level:
		partner.level = SaveState.party.player.level

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


func show_partner_file_menu() -> void:
	var menu: Control = LOAD_PARTNER_MENU.instance()
	MenuHelper.add_child(menu)
	menu.show()
	menu.connect("canceled", self, "_on_load_partner_menu_cancelled")
	menu.connect("partner_selected", self, "_on_partner_selected")
	yield (menu, "hidden")
	menu.queue_free()
	menu = null


func _on_load_partner_menu_cancelled() -> void:
	selection = -1


func _on_partner_selected(partner_index: int) -> void:
	selection = partner_index
