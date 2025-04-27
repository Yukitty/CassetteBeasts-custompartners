extends Action


const PARTNER_CHARACTER_CREATION_MENU_SCENE: PackedScene = preload("res://mods/cat_custompartners/partner_character_creation_menu.tscn")


export var partner_id: String
export var cancelable: bool = true
export var reset_partner: bool = false


func _run() -> bool:
	var partner: Character
	if partner_id.empty():
		partner_id = SaveState.party.current_partner_id

	if reset_partner:
		# Discard previous partner Character
		partner = SaveState.party.get_partner_by_id(partner_id)
		SaveState.party.heal_character(partner)
		SaveState.party.partners.erase(partner)
		partner = null
		# Create new partner from source
		for p in SaveState.party.source_partners:
			if p.partner_id == partner_id:
				partner = p.duplicate()
				break
		assert(partner != null)
		SaveState.party.partners.append(partner)
		# Initialize partner name and level
		partner.name = tr(partner.name)
		partner.level = SaveState.party.player.level
	else:
		# Just grab the existing partner for updating
		partner = SaveState.party.get_partner_by_id(partner_id)

	assert(partner != null)
	if partner:
		return _show_character_creation(partner)
	return false


func _show_character_creation(character: Character) -> bool:
	var menu: Control
	# Special menu for custom partners.
	if "mimic_partner_id" in character:
		menu = PARTNER_CHARACTER_CREATION_MENU_SCENE.instance()
	else:
		menu = MenuHelper.scenes.CharacterCreationMenu.instance()
	menu.character = character
	menu.cancelable = cancelable
	menu.hidden_options = []
	menu.initial_randomize = reset_partner
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	menu.queue_free()
	return result
