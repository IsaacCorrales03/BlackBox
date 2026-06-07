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
const Notification = preload("res://scenes/Notification.tscn")
var notification_queue = []
var notification_active = false
var notification_base_y = 16  # posición Y inicial
var turn = 0

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
	
	# posición esquina superior derecha
	notif.rect_position = Vector2(
		get_viewport().size.x - 296,
		notification_base_y
	)
	
	notif.show_message(data["text"], data["color"])
	yield(get_tree().create_timer(3.0), "timeout")
	_show_next_notification()
var bar_base_colors = {}
var current_event = null
var writing = false
var full_text = ""
var prev_stats = {}
var bar_tweens = {}

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
	
	load_event()
	
var blink_tweens = {}

func _get_bars_for_effects(effects: Dictionary) -> Array:
	var map = {
		"money":      money_bar,
		"workers":    workers_bar,
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
	_start_blink(_get_bars_for_effects(current_event["option1"]["effects"]))

func _on_btn_b_hover():
	if current_event == null:
		return
	_start_blink(_get_bars_for_effects(current_event["option2"]["effects"]))

func _on_btn_hover_exit():
	_stop_blink()

func _start_blink(bars: Array):
	_stop_blink()
	for bar in bars:
		var tw = Tween.new()
		add_child(tw)
		tw.interpolate_property(bar, "modulate:a", 1.0, 0.3, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tw.interpolate_property(bar, "modulate:a", 0.3, 1.0, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.6)
		tw.connect("tween_all_completed", self, "_restart_blink_tween", [tw, bar])
		tw.start()
		blink_tweens[bar] = tw

func _restart_blink_tween(tw: Tween, bar):
	if not blink_tweens.has(bar):
		return
	tw.interpolate_property(bar, "modulate:a", 1.0, 0.3, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tw.interpolate_property(bar, "modulate:a", 0.3, 1.0, 0.6, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.6)
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
		"money":      [money_bar,      money_val],
		"workers":    [workers_bar,    workers_val],
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

	tween.tween_property(bar, "value", target_val, 0.5) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	bar.tint_progress = flash_color
	tween.tween_property(bar, "tint_progress", base_color, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	bar_tweens[bar] = tween

func load_event():
	turn += 1
	current_event = EventManager.get_random_event(turn)
	if current_event == null:
		return
	
	# cargar personaje
	var role = current_event.get("character", "")
	var data = EventManager.get_character_data(role)
	if not data.empty():
		$"../char_header/char_asset".texture = load(data["texture"])
		$"../char_header/VBoxContainer/char_name".text = data["name"]
		$"../char_header/VBoxContainer/char_role".text = data["role"]
	opcion_a_text.text = current_event["option1"]["text"]
	opcion_b_text.text = current_event["option2"]["text"]
	set_buttons_disabled(false)
	write_description(current_event["description"])

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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		skip_typing()
	if event is InputEventKey and event.pressed:
		skip_typing()

func set_buttons_disabled(disabled: bool):
	btn_a.disabled = disabled
	btn_b.disabled = disabled

func _on_game_over(reason):
	set_buttons_disabled(true)
	$"../main_theme".stop()
	$"../game_over".play()
	
	write_description("PERDISTE\n\n" + reason + " llegó a 0.")

func _on_opcion_a_button_up():
	if current_event == null or writing:
		return
	if GameManager.apply_effects(current_event["option1"]["effects"]):
		_process_flags(current_event["option1"])
		load_event()
		
func _on_opcion_b_button_up():
	if current_event == null or writing:
		return
	if GameManager.apply_effects(current_event["option2"]["effects"]):
		_process_flags(current_event["option2"])
		load_event()

func _process_flags(option: Dictionary):
	if not option.has("flags_messages"):
		return
	for flag in option.get("flags_add", []):
		if option["flags_messages"].has(flag):
			GameManager.add_flag(flag)
			var is_positive = _flag_is_positive(option["effects"])
			var color = Color("#00FF88") if is_positive else Color("#FF3366")
			queue_notification(option["flags_messages"][flag], color)

func _flag_is_positive(effects: Dictionary) -> bool:
	var total = 0
	for val in effects.values():
		total += val
	return total >= 0
	 
