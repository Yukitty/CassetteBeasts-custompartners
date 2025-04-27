extends "res://world/core/LevelMap.gd"


func _check_level_warning() -> void:
	# Revert to vanilla if not using mimic_partner_id
	if not "mimic_partner_id" in SaveState.party.partner:
		._check_level_warning()
		return

	# Copy of _check_level_warning using mimic_partner_id
	var p: String = SaveState.party.partner.mimic_partner_id
	var level = UserSettings.get_scaled_level("monster", region_settings.battle_level, SaveState.party.player.level)
	if level <= 10:
		return
	if level < 1.2 * SaveState.party.player.level:
		return
	if level_warning_cooldown > 0.0:
		return

	var pname = SaveState.party.partner.name
	GlobalMessageDialog.passive_message.show_message(Loc.trv("LEVEL_WARNING_" + p, randi()), pname if p != "dog" else "")

	level_warning_cooldown = 30.0
