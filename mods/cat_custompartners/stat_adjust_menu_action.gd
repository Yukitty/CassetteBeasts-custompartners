extends "res://nodes/actions/StatAdjustMenuAction.gd"


func _run() -> bool:
	var is_primary_player = not blackboard.has("player") or blackboard.player == null or blackboard.player == WorldSystem.get_player()
	var partner: Character = SaveState.party.partner
	if is_primary_player or not "allow_adjust_base_stats" in partner or not partner.allow_adjust_base_stats:
		return ._run()

	# Open the stat adjust menu for the partner, instead of the primary player.
	var menu = MenuHelper.scenes.StatAdjustMenu.instance()
	menu.character = partner
	MenuHelper.add_child(menu)
	yield (menu.run_menu(), "completed")
	menu.queue_free()
	return true
