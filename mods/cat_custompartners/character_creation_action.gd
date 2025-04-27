extends "res://nodes/actions/CharacterCreationAction.gd"


const PARTNER_CHARACTER_CREATION_MENU_SCENE: PackedScene = preload("res://mods/cat_custompartners/partner_character_creation_menu.tscn")


func _run() -> bool:
	var is_primary_player = not blackboard.has("player") or blackboard.player == null or blackboard.player == WorldSystem.get_player()
	var partner: Character = SaveState.party.partner
	if is_primary_player or not "mimic_partner_id" in partner:
		return ._run()

	return _cat_custompartners_show_character_creation(partner)


func _cat_custompartners_show_character_creation(character: Character, cancelable: bool = true, hidden_options: Array = [], initial_randomize: bool = false) -> bool:
	var menu: Control = PARTNER_CHARACTER_CREATION_MENU_SCENE.instance()
	menu.character = character
	menu.cancelable = cancelable
	menu.hidden_options = hidden_options
	menu.initial_randomize = initial_randomize
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	menu.queue_free()
	return result
