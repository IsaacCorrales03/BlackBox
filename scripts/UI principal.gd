extends Control

onready var dilema_text_label = $TextoPanel/Dilema_text
onready var opcion_a_text = $opcion_a/texto
onready var opcion_b_text = $opcion_b/texto
onready var btn_a = $opcion_a
onready var btn_b = $opcion_b

onready var money_bar = $stats_container/Money_container/money_bar
onready var workers_bar = $stats_container/workers_container/workers_bar
onready var acceptance_bar = $stats_container/acceptance_container/acceptance_bar
onready var innovation_bar = $stats_container/innovation_container/innovation_bar

onready var money_val = $stats_container/Money_container/stat_money/lbl_val
onready var workers_val = $stats_container/workers_container/stat_workers/lbl_val
onready var acceptance_val = $stats_container/acceptance_container/stat_acceptance/lbl_val
onready var innovation_val = $stats_container/innovation_container/stat_innovation/lbl_val
var current_data = {}
const Notification = preload("res://scenes/Notification.tscn")

var notification_queue = []
var notification_active = false
var notification_base_y = 16

var turn = 0
var bar_base_colors = {}
var current_event = null
var normal_event_before_call = null
var current_mode = "event"

var writing = false
var full_text = ""
var prev_stats = {}
var bar_tweens = {}
var blink_tweens = {}

# ══════════════════════════════════════════════════════════════
# READY
# ══════════════════════════════════════════════════════════════

func _ready():
	GameManager.connect("game_over", self, "_on_game_over")
	GameManager.connect("stats_changed", self, "_on_stats_changed")

	bar_base_colors[money_bar]      = money_bar.tint_progress
	bar_base_colors[workers_bar]    = workers_bar.tint_progress
	bar_base_colors[acceptance_bar] = acceptance_bar.tint_progress
	bar_base_colors[innovation_bar] = innovation_bar.tint_progress

	$"../main_theme".play()

	btn_a.connect("mouse_entered", self, "_on_btn_a_hover")
	btn_b.connect("mouse_entered", self, "_on_btn_b_hover")
	btn_a.connect("mouse_exited",  self, "_on_btn_hover_exit")
	btn_b.connect("mouse_exited",  self, "_on_btn_hover_exit")

	_on_stats_changed(GameManager.stats)

	_build_trigger_buttons()
	_build_slide_panel()

	load_event()


# ══════════════════════════════════════════════════════════════
# NOTIFICACIONES
# ══════════════════════════════════════════════════════════════

func queue_notification(text: String, color: Color = Color("#B8D8E8")):
	notification_queue.append({"text": text, "color": color})

	if not notification_active:
		_show_next_notification()


func _show_next_notification():
	if notification_queue.empty():
		notification_active = false
		return

	notification_active = true

	var data = notification_queue.pop_front()
	var notif = Notification.instance()

	get_tree().root.add_child(notif)
	notif.rect_position = Vector2(get_viewport().size.x - 296, notification_base_y)
	notif.show_message(data["text"], data["color"])

	yield(get_tree().create_timer(3.0), "timeout")

	_show_next_notification()


# ══════════════════════════════════════════════════════════════
# EVENTOS NORMALES
# ══════════════════════════════════════════════════════════════

func load_event():
	current_mode = "event"
	normal_event_before_call = null

	turn += 1
	current_event = EventManager.get_next_event()

	if current_event == null:
		return

	_show_event(current_event)


func _show_event(event_data: Dictionary):
	current_event = event_data

	var role = current_event.get("character", "")
	var data = GameManager.get_character_data(role)

	if not data.empty():
		$"../char_header/char_asset".texture = load(data["texture"])
		$"../char_header/VBoxContainer/char_name".text = data["name"]
		$"../char_header/VBoxContainer/char_role".text = data["role"]
		current_data = data
	opcion_a_text.text = current_event["option1"]["text"]
	opcion_b_text.text = current_event["option2"]["text"]

	set_buttons_disabled(false)
	write_description(current_event["description"])


func _on_opcion_a_button_up():
	if current_event == null or writing:
		return

	if current_mode == "call":
		_process_call_option(current_event["option1"])
		return

	_process_normal_option(current_event["option1"])


func _on_opcion_b_button_up():
	if current_event == null or writing:
		return

	if current_mode == "call":
		_process_call_option(current_event["option2"])
		return

	_process_normal_option(current_event["option2"])


func _process_normal_option(option: Dictionary):
	if GameManager.apply_effects(option["effects"]):
		_process_flags(option)
		var trust_delta = int(option.get("trust_add", 0))
		if trust_delta != 0:
			CallManager.add_trust(current_event["character"], trust_delta)
		_process_unlock_files(option)
		register_contact(current_data["id"], current_data["name"], current_data["role"], current_data["texture"])

		load_event()


# ══════════════════════════════════════════════════════════════
# SISTEMA DE LLAMADAS
# ══════════════════════════════════════════════════════════════

func _start_call(contact_id: String):
	if current_mode == "call":
		queue_notification("Ya estás en una llamada.", Color("#FF3366"))
		return

	if not GameManager.can_call():
		queue_notification("No quedan llamadas disponibles hoy.", Color("#FF3366"))
		return

	var call_event = CallManager.get_call_event(contact_id)

	if call_event == null:
		queue_notification("No hay respuesta disponible.", Color("#FF3366"))
		$"../call_sound2".play()
		return

	if not GameManager.use_call():
		queue_notification("No quedan llamadas disponibles hoy.", Color("#FF3366"))
		return

	$"../call_sound".play()
	yield(get_tree().create_timer(1.0), "timeout")

	_close_panel()

	normal_event_before_call = current_event
	current_mode = "call"

	_show_event(call_event)


func _process_call_option(option: Dictionary):
	var character_id = current_event.get("character", "")

	var effects = option.get("effects", {})
	if not effects.empty():
		if not GameManager.apply_effects(effects):
			return

	_process_flags(option)
	_process_unlock_files(option)

	var trust_delta = int(option.get("trust_add", 0))
	if trust_delta != 0:
		CallManager.add_trust(character_id, trust_delta)

	var next_dialogue = str(option.get("next_dialogue", ""))

	if next_dialogue != "":
		var next_event = CallManager.get_dialogue_event(character_id, next_dialogue)

		if next_event != null:
			_show_event(next_event)
			return
		else:
			push_error("No se encontró el siguiente diálogo: " + next_dialogue)

	var should_end = bool(option.get("end_call", true))

	if should_end:
		$"../call_sound2".play()
		write_description("colgando...")
		yield(get_tree().create_timer(1.5), "timeout")
		_restore_event_after_call()


func _restore_event_after_call():
	current_mode = "event"

	if normal_event_before_call == null:
		load_event()
		return

	var restored = normal_event_before_call
	normal_event_before_call = null

	_show_event(restored)


# ══════════════════════════════════════════════════════════════
# FLAGS / ARCHIVOS
# ══════════════════════════════════════════════════════════════

func _process_flags(option: Dictionary):
	if option.has("flags_messages"):
		for flag in option.get("flags_add", []):
			if option["flags_messages"].has(flag):
				GameManager.add_flag(flag)

				var is_positive = _flag_is_positive(option.get("effects", {}))
				var color = Color("#00FF88") if is_positive else Color("#FF3366")

				queue_notification(option["flags_messages"][flag], color)

	for flag in option.get("flags_remove", []):
		if GameManager.flags.has(flag):
			GameManager.flags.erase(flag)


func _process_unlock_files(option: Dictionary):
	for file_data in option.get("unlock_files", []):
		var title = file_data.get("title", "Archivo")
		var content = file_data.get("content", "")

		add_archivo(title, content)
		queue_notification("Archivo desbloqueado: " + title, Color("#00C896"))


func _flag_is_positive(effects: Dictionary) -> bool:
	var total = 0

	for val in effects.values():
		total += val

	return total >= 0


# ══════════════════════════════════════════════════════════════
# TYPEWRITER
# ══════════════════════════════════════════════════════════════

func write_description(text):
	$"../typewritter".play()

	full_text = text

	if writing:
		return

	writing = true
	dilema_text_label.text = ""

	for i in range(text.length()):
		if not writing:
			break

		dilema_text_label.text += text[i]
		yield(get_tree().create_timer(0.01), "timeout")

	dilema_text_label.text = full_text
	writing = false

	$"../typewritter".stop()


func skip_typing():
	if writing:
		$"../typewritter".stop()
		writing = false
		dilema_text_label.text = full_text


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		skip_typing()

	if event is InputEventKey and event.pressed:
		skip_typing()


func set_buttons_disabled(disabled: bool):
	btn_a.disabled = disabled
	btn_b.disabled = disabled


# ══════════════════════════════════════════════════════════════
# BARRAS / STATS
# ══════════════════════════════════════════════════════════════

func _get_bars_for_effects(effects: Dictionary) -> Array:
	var map = {
		"money": money_bar,
		"workers": workers_bar,
		"acceptance": acceptance_bar,
		"innovation": innovation_bar
	}

	var result = []

	for key in effects:
		if map.has(key):
			result.append(map[key])

	return result


func _on_btn_a_hover():
	if current_event == null:
		return

	_start_blink(_get_bars_for_effects(current_event["option1"].get("effects", {})))


func _on_btn_b_hover():
	if current_event == null:
		return

	_start_blink(_get_bars_for_effects(current_event["option2"].get("effects", {})))


func _on_btn_hover_exit():
	_stop_blink()


func _start_blink(bars: Array):
	_stop_blink()

	for bar in bars:
		var tw = Tween.new()
		add_child(tw)

		tw.interpolate_property(
			bar,
			"modulate:a",
			1.0,
			0.3,
			0.6,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT
		)

		tw.interpolate_property(
			bar,
			"modulate:a",
			0.3,
			1.0,
			0.6,
			Tween.TRANS_SINE,
			Tween.EASE_IN_OUT,
			0.6
		)

		tw.connect("tween_all_completed", self, "_restart_blink_tween", [tw, bar])
		tw.start()

		blink_tweens[bar] = tw


func _restart_blink_tween(tw: Tween, bar):
	if not blink_tweens.has(bar):
		return

	tw.interpolate_property(
		bar,
		"modulate:a",
		1.0,
		0.3,
		0.6,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT
	)

	tw.interpolate_property(
		bar,
		"modulate:a",
		0.3,
		1.0,
		0.6,
		Tween.TRANS_SINE,
		Tween.EASE_IN_OUT,
		0.6
	)

	tw.start()


func _stop_blink():
	for bar in blink_tweens:
		var tw = blink_tweens[bar]

		if is_instance_valid(tw):
			tw.stop_all()
			tw.queue_free()

		if is_instance_valid(bar):
			bar.modulate.a = 1.0

	blink_tweens.clear()


func _on_stats_changed(stats):
	var bars = {
		"money": [money_bar, money_val],
		"workers": [workers_bar, workers_val],
		"acceptance": [acceptance_bar, acceptance_val],
		"innovation": [innovation_bar, innovation_val]
	}

	for stat in bars:
		var bar = bars[stat][0]
		var lbl = bars[stat][1]

		var new_val = stats[stat]
		var old_val = prev_stats.get(stat, -1)

		lbl.text = str(int(new_val))

		if new_val < old_val:
			animate_bar(bar, new_val, Color("#FF3366"))
		elif new_val > old_val:
			animate_bar(bar, new_val, Color("#00FF88"))
		else:
			bar.value = new_val

	prev_stats = stats.duplicate()


func animate_bar(bar: TextureProgress, target_val: float, flash_color: Color):
	if bar == null:
		return

	if bar_tweens.has(bar) and is_instance_valid(bar_tweens[bar]):
		bar_tweens[bar].kill()

	var base_color = bar_base_colors.get(bar, Color.white)

	var tween = get_tree().create_tween()
	tween.set_parallel(true)

	tween.tween_property(bar, "value", target_val, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	bar.tint_progress = flash_color

	tween.tween_property(bar, "tint_progress", base_color, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	bar_tweens[bar] = tween


# ══════════════════════════════════════════════════════════════
# GAME OVER
# ══════════════════════════════════════════════════════════════

func _on_game_over(reason):
	set_buttons_disabled(true)

	$"../main_theme".stop()
	$"../game_over".play()

	write_description("PERDISTE\n\n" + reason + " llegó a 0.")


# ══════════════════════════════════════════════════════════════
# PANEL DE CONTACTOS Y ARCHIVOS
# ══════════════════════════════════════════════════════════════

const PANEL_W = 636
const PANEL_H = 480
const ANIM_SPEED = 0.18

const C_BG = Color("0D1520")
const C_BORDER = Color("1A3040")
const C_ACCENT = Color("00C896")
const C_BLUE = Color("00AAFF")
const C_TEXT = Color("B8D8E8")
const C_LABEL = Color("5A7A8A")
const C_PANEL = Color("080C10")

var panel_open: String = ""
var contacts: Array = []
var archivos: Array = []

var btn_llamar: Button
var btn_archivos: Button
var slide_panel: PanelContainer
var panel_title: Label
var scroll: ScrollContainer
var list_box: VBoxContainer

signal contact_selected(contact_id)


func _build_trigger_buttons():
	btn_llamar = _make_btn("[ LLAMAR ]", C_BLUE)
	btn_llamar.rect_position = Vector2(668, 416)
	btn_llamar.rect_size = Vector2(162, 40)
	btn_llamar.connect("pressed", self, "_on_llamar_pressed")
	add_child(btn_llamar)

	btn_archivos = _make_btn("[ ARCHIVOS ]", C_ACCENT)
	btn_archivos.rect_position = Vector2(846, 416)
	btn_archivos.rect_size = Vector2(162, 40)
	btn_archivos.connect("pressed", self, "_on_archivos_pressed")
	add_child(btn_archivos)


func _make_btn(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.flat = true

	var sn = StyleBoxFlat.new()
	sn.bg_color = C_BG
	sn.border_color = color
	sn.set_border_width_all(1)

	var sh = StyleBoxFlat.new()
	sh.bg_color = color
	sh.bg_color.a = 0.12
	sh.border_color = color
	sh.set_border_width_all(1)

	btn.add_stylebox_override("normal", sn)
	btn.add_stylebox_override("hover", sh)
	btn.add_stylebox_override("pressed", sh)
	btn.add_stylebox_override("focus", sn)

	btn.add_color_override("font_color", color)
	btn.add_color_override("font_color_hover", C_TEXT)
	btn.add_color_override("font_color_pressed", C_TEXT)

	_set_font(btn, 11)

	return btn


func _build_slide_panel():
	slide_panel = PanelContainer.new()
	slide_panel.rect_size = Vector2(PANEL_W, PANEL_H)

	var bg = StyleBoxFlat.new()
	bg.bg_color = C_PANEL
	bg.border_color = C_BORDER
	bg.set_border_width_all(1)

	slide_panel.add_stylebox_override("panel", bg)
	slide_panel.set_as_toplevel(true)
	slide_panel.rect_position = Vector2(-PANEL_W, 16)
	slide_panel.visible = false

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	vbox.margin_left = 14
	vbox.margin_right = 14
	vbox.margin_top = 12
	vbox.margin_bottom = 12
	vbox.add_constant_override("separation", 8)

	slide_panel.add_child(vbox)

	var header = HBoxContainer.new()
	header.add_constant_override("separation", 0)
	vbox.add_child(header)

	panel_title = Label.new()
	panel_title.text = "CONTACTOS"
	panel_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_title.add_color_override("font_color", C_BLUE)
	_set_font(panel_title, 12, true)
	header.add_child(panel_title)

	var btn_x = Button.new()
	btn_x.text = "✕"
	btn_x.flat = true
	btn_x.rect_min_size = Vector2(28, 28)
	btn_x.add_color_override("font_color", C_LABEL)
	btn_x.add_color_override("font_color_hover", C_TEXT)

	var es = StyleBoxEmpty.new()
	btn_x.add_stylebox_override("normal", es)
	btn_x.add_stylebox_override("hover", es)
	btn_x.add_stylebox_override("pressed", es)
	btn_x.add_stylebox_override("focus", es)

	_set_font(btn_x, 13)

	btn_x.connect("pressed", self, "_close_panel")
	header.add_child(btn_x)

	var sep = HSeparator.new()
	var ss = StyleBoxFlat.new()
	ss.bg_color = C_BORDER
	sep.add_stylebox_override("separator", ss)
	vbox.add_child(sep)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.scroll_horizontal_enabled = false
	vbox.add_child(scroll)

	list_box = VBoxContainer.new()
	list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_box.add_constant_override("separation", 6)
	scroll.add_child(list_box)

	add_child(slide_panel)


func register_contact(id: String, display_name: String, role: String, portrait_path: String):
	for c in contacts:
		if c.id == id:
			return

	contacts.append({
		"id": id,
		"name": display_name,
		"role": role,
		"portrait": portrait_path
	})


func add_archivo(title: String, content: String):
	archivos.append({
		"title": title,
		"content": content,
		"read": false
	})


func _on_llamar_pressed():
	if panel_open == "llamar":
		_close_panel()
		return

	panel_open = "llamar"
	panel_title.text = "CONTACTOS"
	panel_title.add_color_override("font_color", C_BLUE)

	_populate_contacts()
	_open_panel()


func _on_archivos_pressed():
	if panel_open == "archivos":
		_close_panel()
		return

	panel_open = "archivos"
	panel_title.text = "ARCHIVOS"
	panel_title.add_color_override("font_color", C_ACCENT)

	_populate_archivos()
	_open_panel()


func _populate_contacts():
	_clear_list()

	if contacts.empty():
		_empty_label("Sin contactos aún.")
		return

	for c in contacts:
		_add_contact_row(c)


func _add_contact_row(c: Dictionary):
	var container = PanelContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var sn = StyleBoxFlat.new()
	sn.bg_color = Color("111D2A")
	sn.border_color = C_BORDER
	sn.set_border_width_all(1)
	sn.content_margin_left = 10
	sn.content_margin_right = 10
	sn.content_margin_top = 10
	sn.content_margin_bottom = 10

	container.add_stylebox_override("panel", sn)

	var btn = Button.new()
	btn.flat = true
	btn.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	btn.rect_min_size = Vector2(0, 64)

	var btn_normal = StyleBoxEmpty.new()

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = C_BLUE
	btn_hover.bg_color.a = 0.10
	btn_hover.border_color = C_BLUE
	btn_hover.set_border_width_all(1)

	btn.add_stylebox_override("normal", btn_normal)
	btn.add_stylebox_override("hover", btn_hover)
	btn.add_stylebox_override("pressed", btn_hover)
	btn.add_stylebox_override("focus", btn_normal)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	hbox.add_constant_override("separation", 12)
	btn.add_child(hbox)

	var portrait = TextureRect.new()
	portrait.rect_min_size = Vector2(48, 48)
	portrait.rect_size = Vector2(48, 48)
	portrait.expand = true
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	if ResourceLoader.exists(c.portrait):
		portrait.texture = load(c.portrait)

	hbox.add_child(portrait)

	var vline = ColorRect.new()
	vline.rect_min_size = Vector2(1, 0)
	vline.color = C_BLUE
	vline.color.a = 0.4
	vline.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(vline)

	var vb = VBoxContainer.new()
	vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	vb.add_constant_override("separation", 3)
	hbox.add_child(vb)

	var lname = Label.new()
	lname.text = c.name
	lname.add_color_override("font_color", C_TEXT)
	_set_font(lname, 12, true)
	vb.add_child(lname)

	var lrole = Label.new()
	lrole.text = c.role
	lrole.add_color_override("font_color", C_LABEL)
	_set_font(lrole, 10)
	vb.add_child(lrole)

	var trust = 0

	if Engine.has_singleton("CallManager"):
		trust = CallManager.get_trust(c.id)
	else:
		trust = CallManager.get_trust(c.id)

	var calls_left = GameManager.get_calls_left()

	var lcall = Label.new()

	if calls_left > 0:
		lcall.text = "LLAMAR ›  CONFIANZA " + str(trust) + "/3  |  LLAMADAS " + str(calls_left)
		lcall.add_color_override("font_color", C_BLUE)
	else:
		lcall.text = "SIN LLAMADAS DISPONIBLES"
		lcall.add_color_override("font_color", Color("#FF3366"))

	_set_font(lcall, 9)
	vb.add_child(lcall)
	lcall.add_color_override("font_color", C_BLUE)
	_set_font(lcall, 9)
	vb.add_child(lcall)

	btn.connect("pressed", self, "_on_contact_pressed", [c.id])

	container.add_child(btn)
	list_box.add_child(container)


func _populate_archivos():
	_clear_list()

	if archivos.empty():
		_empty_label("Sin archivos desbloqueados.")
		return

	for a in archivos:
		_add_archivo_row(a)


func _add_archivo_row(a: Dictionary):
	var btn = Button.new()
	btn.flat = true
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.rect_min_size = Vector2(0, 44)

	var bc = C_ACCENT if not a.read else C_BORDER

	var sn = StyleBoxFlat.new()
	sn.bg_color = C_BG
	sn.border_color = bc
	sn.set_border_width_all(1)

	var sh = StyleBoxFlat.new()
	sh.bg_color = C_ACCENT
	sh.bg_color.a = 0.08
	sh.border_color = C_ACCENT
	sh.set_border_width_all(1)

	btn.add_stylebox_override("normal", sn)
	btn.add_stylebox_override("hover", sh)
	btn.add_stylebox_override("pressed", sh)
	btn.add_stylebox_override("focus", sn)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	hbox.margin_left = 10
	hbox.margin_right = 8
	hbox.margin_top = 8
	hbox.margin_bottom = 8
	hbox.add_constant_override("separation", 8)

	btn.add_child(hbox)

	var dot = Label.new()
	dot.text = "●" if not a.read else "○"
	dot.add_color_override("font_color", C_ACCENT)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_set_font(dot, 8)
	hbox.add_child(dot)

	var lbl = Label.new()
	lbl.text = a.title
	lbl.add_color_override("font_color", C_TEXT)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.clip_text = true
	_set_font(lbl, 10)
	hbox.add_child(lbl)

	btn.connect("pressed", self, "_on_archivo_pressed", [a.title])

	list_box.add_child(btn)


func _empty_label(text: String):
	var lbl = Label.new()
	lbl.text = text
	lbl.add_color_override("font_color", C_LABEL)
	lbl.align = Label.ALIGN_CENTER
	_set_font(lbl, 10)
	list_box.add_child(lbl)


func _clear_list():
	for child in list_box.get_children():
		child.queue_free()


func _on_archivo_pressed(title: String):
	for a in archivos:
		if a.title == title:
			a.read = true
			_show_detail(a)
			break


func _show_detail(a: Dictionary):
	_clear_list()

	var btn_back = Button.new()
	btn_back.text = "← VOLVER"
	btn_back.flat = true
	btn_back.add_color_override("font_color", C_LABEL)
	btn_back.add_color_override("font_color_hover", C_TEXT)

	var es = StyleBoxEmpty.new()
	btn_back.add_stylebox_override("normal", es)
	btn_back.add_stylebox_override("hover", es)
	btn_back.add_stylebox_override("pressed", es)
	btn_back.add_stylebox_override("focus", es)

	_set_font(btn_back, 10)

	btn_back.connect("pressed", self, "_populate_archivos")

	list_box.add_child(btn_back)

	var sep = HSeparator.new()
	var ss = StyleBoxFlat.new()
	ss.bg_color = C_BORDER
	sep.add_stylebox_override("separator", ss)
	list_box.add_child(sep)

	var ltitle = Label.new()
	ltitle.text = a.title
	ltitle.add_color_override("font_color", C_ACCENT)
	ltitle.autowrap = true
	_set_font(ltitle, 11, true)
	list_box.add_child(ltitle)

	var lcontent = Label.new()
	lcontent.text = a.content
	lcontent.add_color_override("font_color", C_TEXT)
	lcontent.autowrap = true
	_set_font(lcontent, 10)
	list_box.add_child(lcontent)


func _open_panel():
	slide_panel.visible = true

	var tw = Tween.new()
	add_child(tw)

	tw.interpolate_property(
		slide_panel,
		"rect_position:x",
		-PANEL_W,
		16,
		ANIM_SPEED,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)

	tw.start()


func _close_panel():
	panel_open = ""

	var tw = Tween.new()
	add_child(tw)

	tw.interpolate_property(
		slide_panel,
		"rect_position:x",
		slide_panel.rect_position.x,
		-PANEL_W,
		ANIM_SPEED,
		Tween.TRANS_QUART,
		Tween.EASE_IN
	)

	tw.start()

	yield(tw, "tween_all_completed")

	slide_panel.visible = false
	tw.queue_free()


func _on_contact_pressed(contact_id: String):
	emit_signal("contact_selected", contact_id)
	_start_call(contact_id)
	


# ══════════════════════════════════════════════════════════════
# FONT HELPER
# ══════════════════════════════════════════════════════════════

func _set_font(node: Control, size: int, bold: bool = false):
	var font = DynamicFont.new()
	var fd = DynamicFontData.new()

	fd.font_path = "res://assets/fonts/JetBrainsMono-Bold.ttf" if bold else "res://assets/fonts/JetBrainsMono-Regular.ttf"

	font.font_data = fd
	font.size = size

	node.add_font_override("font", font)
