extends "res://menus/character_creation/CharacterCreationMenu.gd"


onready var mimic_option: ArrowOptionList = input_container.get_node(@"Field_CatCustomPartnersMimic")


func _on_SaveButton_pressed() -> void:
	assert("mimic_partner_id" in character)
	if "mimic_partner_id" in character:
		assert(mimic_option != null)
		character.mimic_partner_id = mimic_option.selected_value
	._on_SaveButton_pressed()
