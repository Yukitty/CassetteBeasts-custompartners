extends "res://nodes/actions/CheckConditionAction.gd"


const CAT_CUSTOMPARTNERS_REJECT_FLAGS := PoolStringArray(["player_has_romanced"])


# conds is usually a Node (Action or Spatial), but I would accept a Dictionary as well.
static func check_conditions(conds) -> bool:
	# Debug print to make sure everything is working okay.
	if Debug.is_verbose_logging():
		if conds is Node:
			if not conds.filename.empty():
				print("cat_custompartners: Checking conds for ", conds.filename, ":", conds.name)
			elif conds.owner and not conds.owner.filename.empty():
				print("cat_custompartners: Checking conds for ", conds.owner.filename, ":", conds.owner.name, "/", conds.owner.get_path_to(conds))

	# First off, immediately revert to vanilla if the partner isn't being checked.
	var partner: Character = SaveState.party.partner
	if not "mimic_partner_id" in partner:
		return .check_conditions(conds)

	# If the custom partner is specifically denied,
	# we can handle that quickly by ourselves.
	if "deny_partner_id" in conds and not conds.deny_partner_id.empty():
		var parts = conds.deny_partner_id.split(",")
		if partner.partner_id in parts:
			return false

	# If the custom partner is specifically requested,
	# allow mimic to be checked.
	var real_partner_id: String
	var result: bool
	if "require_partner_id" in conds:
		var partner_id: PoolStringArray = conds.require_partner_id.split(':', true, 1)
		if partner_id[0] == partner.partner_id and \
		(partner_id.size() == 1 or partner_id[1].empty() or partner_id[1] == partner.mimic_partner_id):
			real_partner_id = partner.partner_id
			partner.partner_id = conds.require_partner_id
			result = .check_conditions(conds)
			partner.partner_id = real_partner_id
			return result

	# If any of the reject flags appear, reveal the mimic.
	var _blackboard: Dictionary = conds.blackboard if "blackboard" in conds else {}
	if "one_time_flag" in conds and conds.one_time_flag in CAT_CUSTOMPARTNERS_REJECT_FLAGS:
		_blackboard.cat_custompartners_reveal = true
	elif "deny_flags" in conds:
		for flag in conds.deny_flags:
			if flag in CAT_CUSTOMPARTNERS_REJECT_FLAGS:
				_blackboard.cat_custompartners_reveal = true
				break

	# If mimic is revealed, revert to vanilla.
	if "cat_custompartners_reveal" in _blackboard:
		return .check_conditions(conds)

	# Hack partner id to pass checks for the mimic partner.
	real_partner_id = partner.partner_id
	partner.partner_id = partner.mimic_partner_id
	result = .check_conditions(conds)
	partner.partner_id = real_partner_id
	return result
