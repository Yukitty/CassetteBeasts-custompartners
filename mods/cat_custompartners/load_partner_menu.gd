extends SlidingControl


signal partner_selected (partner_index)


const PARTNER_BUTTON_SCENE: PackedScene = preload("res://mods/cat_custompartners/partner_button.tscn")
const PartnerButton: GDScript = preload("res://mods/cat_custompartners/partner_button.gd")
const StatHex: GDScript = preload("res://menus/party_character/StatHex.gd")
const RelationshipMeter: GDScript = preload("res://menus/party/RelationshipMeter.gd")

const PARTNER_PORTRAITS = {
	"kayleigh": preload("res://sprites/portraits/kayleigh.png"),
	"meredith": preload("res://sprites/portraits/meredith.png"),
	"eugene": preload("res://sprites/portraits/eugene.png"),
	"felix": preload("res://sprites/portraits/felix.png"),
	"viola": preload("res://sprites/portraits/viola.png"),
	"sunny": preload("res://sprites/portraits/sunny_new_default.png"),
	"dog": preload("res://sprites/portraits/dog.png"),
}


onready var partner_button_container: BoxContainer = get_node(@"%PartnerButtonContainer")
onready var partner_name_label: Label = get_node(@"%PartnerNameLabel")
onready var partner_level_label: Label = get_node(@"%PartnerLevelLabel")
onready var partner_sprite: LayeredSprite = get_node(@"%PartnerSprite")
onready var partner_portrait: TextureRect = get_node(@"%PartnerPortrait")
onready var relationship_meter: RelationshipMeter = get_node(@"%RelationshipMeter")
onready var tape_name_label: Label = get_node(@"%TapeNameLabel")
onready var type_icon_container: Container = get_node(@"%TypeIconContainer")
onready var monster_sticker: TextureRect = get_node(@"%MonsterSticker")
onready var stat_hex: StatHex = get_node(@"%StatHex")


var thumbnail_tween: Tween
var current_partner: Character


func _ready() -> void:
	assert("cat_custompartners" in SaveState.party)
	if not "cat_custompartners" in SaveState.party or SaveState.party.cat_custompartners.empty():
		return

	thumbnail_tween = Tween.new()
	add_child(thumbnail_tween)

	# Generate save file buttons from partner list,
	# limit to the first 10 partners
	for partner in SaveState.party.cat_custompartners.slice(0, 9):
		var button: PartnerButton = PARTNER_BUTTON_SCENE.instance()
		button.partner = partner
		partner_button_container.add_child(button)
		button.connect("focus_entered", self, "_on_partner_focused", [partner])
		button.connect("pressed", self, "_on_partner_pressed", [partner])

	partner_button_container.setup_focus()

	# if more partners exist, slowly add them to the list while playing
	var i: int = 10
	while i < SaveState.party.cat_custompartners.size():
		yield(Co.wait(0.2), "completed")
		for partner in SaveState.party.cat_custompartners.slice(i, i+9):
			var button: PartnerButton = PARTNER_BUTTON_SCENE.instance()
			button.partner = partner
			partner_button_container.add_child(button)
			button.connect("focus_entered", self, "_on_partner_focused", [partner])
			button.connect("pressed", self, "_on_partner_pressed", [partner])
		partner_button_container.setup_focus()
		i += 10


func grab_focus() -> void:
	partner_button_container.grab_focus()


func _on_partner_focused(partner: Character) -> void:
	if current_partner == partner:
		return

	current_partner = partner

	# Update name
	partner_name_label.text = partner.name
	partner_level_label.text = Loc.trf("UI_CHARACTER_LEVEL", ["%02d" % partner.level])

	# Update sprite
	partner_sprite.part_names = partner.human_part_names.duplicate()
	partner_sprite.colors = partner.human_colors.duplicate()
	partner_sprite.refresh()

	# Update mimic portrait
	partner_portrait.texture = null
	assert("mimic_partner_id" in partner)
	if "mimic_partner_id" in partner:
		if partner.mimic_partner_id in PARTNER_PORTRAITS:
			partner_portrait.texture = PARTNER_PORTRAITS[partner.mimic_partner_id]
#		var cutscene_partner: Character = SaveState.party.get_partner_by_id(partner.mimic_partner_id)
#		if cutscene_partner:
#			cutscene_partner_label.text = cutscene_partner.name

	# Update relationship level
	relationship_meter.set_character(partner)

	# Update stats
	stat_hex.set_stats_for(partner, null)

	# Update tape name and type
	assert(not partner.tapes.empty())
	if not partner.tapes.empty():
		_update_tape_info(partner.tapes[0])


func _update_tape_info(tape: MonsterTape) -> void:
	tape_name_label.text = tape.get_name()
	var form: MonsterForm = tape.create_form()
	var types: Array = form.elemental_types if form else []
	for child in type_icon_container.get_children():
		type_icon_container.remove_child(child)
		child.queue_free()
	for type in types:
		var icon = TextureRect.new()
		icon.expand = true
		icon.rect_min_size = Vector2(42, 42)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.texture = type.icon
		type_icon_container.add_child(icon)
	monster_sticker.texture = form.tape_sticker_texture if form else null


func _on_PlayButton_pressed() -> void:
	_on_partner_pressed(current_partner)


func _on_partner_pressed(partner: Character) -> void:
	emit_signal("partner_selected", SaveState.party.cat_custompartners.find(partner))
	hide()


func _on_EraseButton_pressed() -> void:
	var button: PartnerButton = partner_button_container.get_child(SaveState.party.cat_custompartners.find(current_partner))
	assert(button.partner == current_partner)
	if button.partner != current_partner:
		return
	if yield (MenuHelper.confirm("UI_SAVE_ERASE_CONFIRM", 1, 1), "completed") and not SceneManager.transitioning:
		partner_button_container.remove_child(button)
		button.queue_free()
		SaveState.party.cat_custompartners.erase(current_partner)
		for tape in current_partner.tapes:
			SaveState.tape_collection.add_tape(tape)
		current_partner.tapes = []
		current_partner = null
		if partner_button_container.get_child_count() < 1:
			cancel()
		else:
			partner_button_container.grab_focus()
