extends "res://nodes/partners/SwapPartnerAction.gd"


# I had to copy the entire run function just to add a single yield...
func _run() -> bool:
	var pawn = get_pawn()
	var current_partner = WorldSystem.get_partner()
	
	var message = Loc.trgf("PARTNER_SWAP_CONFIRM", pawn.character.pronouns, {
		"name": pawn.character.name
	})
	
	if yield (MenuHelper.confirm(message), "completed"):
		var co = swap_partners(pawn, current_partner)
		if co is GDScriptFunctionState:
			yield(co, "completed")
		return true
	return false


func swap_partners(pawn: NPC, current_partner: NPC) -> void:
	# Disappear any partners who don't have a place to sit.
	# This mimics the behavior of UnlockPartnerAction.
	if not idle_positions.has(current_partner.character.partner_id):
		detach_root()
		SceneManager.transition = SceneManager.TransitionKind.TRANSITION_FADE
		yield (SceneManager.transition_out(), "completed")
		current_partner.get_parent().remove_child(current_partner)
		current_partner.queue_free()
		current_partner = null
		yield (SceneManager.transition_in(), "completed")

	# Do the rest as in vanilla.
	.swap_partners(pawn, current_partner)
