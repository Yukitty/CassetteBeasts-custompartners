extends ContentInfo


const REPLACE: Dictionary = {
	"res://mods/cat_custompartners/check_condition_action.gd":
		"res://nodes/actions/CheckConditionAction.gd",
	"res://mods/cat_custompartners/cutscene.gd":
		"res://nodes/actions/Cutscene.gd",
	"res://mods/cat_custompartners/swap_partner_action.gd":
		"res://nodes/partners/SwapPartnerAction.gd",
	"res://mods/cat_custompartners/character_creation_action.gd":
		"res://nodes/actions/CharacterCreationAction.gd",
	"res://mods/cat_custompartners/stat_adjust_menu_action.gd":
		"res://nodes/actions/StatAdjustMenuAction.gd",
	"res://mods/cat_custompartners/party.gd":
		"res://global/save_state/Party.gd",
	"res://mods/cat_custompartners/level_map.gd":
		"res://world/core/LevelMap.gd",
	"res://mods/cat_custompartners/player_wardrobe.tscn":
		"res://world/objects/static_physics/player_home/PlayerWardrobe.tscn",
	"res://mods/cat_custompartners/kayleigh_quest1_part1.tscn":
		"res://cutscenes/kayleigh_quest/KayleighQuest1_Part1.tscn",
	"res://mods/cat_custompartners/kayleigh_quest1_part2.tscn":
		"res://cutscenes/kayleigh_quest/KayleighQuest1_Part2.tscn",
	"res://mods/cat_custompartners/battle_vortex.tscn":
		"res://battle/backgrounds/BattleVortex.tscn",
}


const CAMPING_CUTSCENES := PoolStringArray([
	"res://mods/cat_custompartners/kayleigh_relationship_2.tscn",
	"res://mods/cat_custompartners/fallback_relationship_up.tscn",
])


const MODUTILS: Dictionary = {
	"updates": "https://gist.githubusercontent.com/Yukitty/f113b1e2c11faad763a47ebc0a867643/raw/updates.json",
}


# Script-modified Resources MUST remain loaded in
# some global var, or else the changes will be lost.
# This includes take_over_path getting reverted.
var _res_cache: Array = []


func init_content() -> void:
	# Merge translation analysis
	var mod_analysis: TranslationAnalysis = load("res://mods/cat_custompartners/translation_analysis.tres")
	assert(Loc.translation_analysis)
	Loc.translation_analysis.variant_counts.merge(mod_analysis.variant_counts)
	Loc.translation_analysis.pronouns.merge(mod_analysis.pronouns)

	# Merge resources
	var res: Resource
	for k in REPLACE.keys():
		res = load(k)
		assert(res is Resource)
		res.take_over_path(REPLACE[k])
		_res_cache.append(res)

	# Add extra camping cutscene(s)
	var table: Dictionary = Datatables.load("res://cutscenes/camping", "tscn").table
	for path in CAMPING_CUTSCENES:
		table[Datatables.get_db_key(path)] = load(path)

	# Finish initialization later
	assert(not SceneManager.preloader.singleton_setup_complete)
	yield(SceneManager.preloader, "singleton_setup_completed")

	# Add custom partner source
	var custom_partner: Character = load("res://mods/cat_custompartners/custom_partner.tres")
	SaveState.party.source_partners.append(custom_partner)
	SaveState.party.initial_partner_levels[custom_partner.partner_id] = 10

	# "Test World" party setup
	custom_partner = custom_partner.duplicate()
	custom_partner.name = tr(custom_partner.name)
	SaveState.party._make_tapes_unique(custom_partner)
	SaveState.party.partners.push_back(custom_partner)
	SaveState.party.unlocked_partners.push_back(custom_partner.partner_id)
