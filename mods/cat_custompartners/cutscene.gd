extends "res://nodes/actions/Cutscene.gd"


func conditions_met() -> bool:
	if root == null:
		setup()
	var CheckConditionActionMods: GDScript = load("res://nodes/actions/CheckConditionAction.gd")
	return CheckConditionActionMods.check_conditions(self)
