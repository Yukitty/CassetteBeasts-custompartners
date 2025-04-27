extends HighlightOnFocus


onready var partner_name_label: Label = get_node(@"%PartnerNameLabel")
onready var partner_level_label: Label = get_node(@"%PartnerLevelLabel")
onready var monster_sticker: TextureRect = get_node(@"%MonsterSticker")
onready var reels: Control = get_node(@"%Reels")


export (Resource) var partner # : Character


var reels_tween: Tween


func _ready() -> void:
	assert(partner is Character)
	reels_tween = Tween.new()
	add_child(reels_tween)
	reels_tween.repeat = true
	for node in reels.get_children():
		reels_tween.interpolate_property(node, @"rect_rotation", node.rect_rotation, node.rect_rotation + 360.0, 2.0)
	reels_tween.start()
	reels_tween.stop_all()

	if not partner is Character:
		return

	partner_name_label.text = partner.name
	partner_level_label.text = Loc.trf("UI_CHARACTER_LEVEL", ["%02d" % partner.level])
#	assert(not partner.tapes.empty())
#	if partner.tapes.empty():
#		monster_sticker.hide()
#	else:
#		var tape: MonsterTape = partner.tapes[0]
#		var form: MonsterForm = tape.form
#		monster_sticker.texture = form.tape_sticker_texture


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_ENTER:
			play_animation()
		NOTIFICATION_FOCUS_EXIT:
			stop_animation()


func play_animation() -> void:
	reels_tween.resume_all()


func stop_animation() -> void:
	reels_tween.stop_all()
