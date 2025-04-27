extends Action


func _run() -> void:
	var tapes = SaveState.party.get_tapes()
	var tape = yield (MenuHelper.show_choose_tape_menu(tapes, Bind.new(self, "_tape_filter")), "completed")
	if not tape:
		return false

	assert (tape.form != null)
	blackboard.starter_tape = tape
	return true


func _tape_filter(tape: MonsterTape) -> bool:
	return SaveState.party.player.tapes.find(tape) != 0 and SaveState.party.partner.tapes.find(tape) != 0 and not tape.is_broken()
