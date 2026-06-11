extends Node

var events = []

var daily_plan := []
var daily_index: int = 0
var planned_day := -1

func _ready() -> void:
	randomize()
	load_events()


# =========================
# CARGA DE EVENTOS
# =========================

func load_events() -> void:
	var file = File.new()

	if not file.file_exists("res://data/events.json"):
		push_error("No se encontró events.json")
		return

	var error = file.open("res://data/events.json", File.READ)

	if error != OK:
		push_error("No se pudo abrir events.json")
		return

	var json_text = file.get_as_text()
	file.close()

	var parsed = JSON.parse(json_text)

	if parsed.error != OK:
		push_error("Error al parsear JSON")
		return

	events = parsed.result


# =========================
# PLAN DEL DÍA
# =========================

const EVENTS_PER_DAY := 7
const STORY_MIN_POSITION := 5
const STORY_MAX_POSITION := 7


func build_day_plan(day: int) -> Array:
	daily_plan.clear()
	daily_index = 0
	planned_day = day

	var slots := []

	for _i in range(EVENTS_PER_DAY):
		slots.append(null)

	# Historia solo puede ir en posición 5, 6 o 7.
	var story_position = STORY_MIN_POSITION + (randi() % (STORY_MAX_POSITION - STORY_MIN_POSITION + 1))
	var story_index = story_position - 1

	var story_event = _pick_from_available(day, "story")
	if story_event != null:
		slots[story_index] = story_event

	# Evento condicional.
	_place_event_in_random_empty_slot(slots, day, "conditional")

	# Cita del director.
	_place_director_appointment_in_random_empty_slot(slots, day)

	# Rellenar el resto con eventos normales.
	for i in range(slots.size()):
		if slots[i] == null:
			slots[i] = _pick_from_available(day, "normal")

	# Limpiar posibles null si faltaron eventos.
	for event in slots:
		if event != null:
			daily_plan.append(event)

	return daily_plan
	
func _pick_from_available(day: int, event_type: String):
	var pool = get_available_events(day, event_type)

	if pool.size() == 0:
		return null

	var event = _pick_weighted_event(pool)

	if event == null:
		return null

	GameManager.mark_event_used(event["id"])

	return event
	
	
func _place_event_in_random_empty_slot(slots: Array, day: int, event_type: String) -> void:
	var event = _pick_from_available(day, event_type)

	if event == null:
		return

	var empty_indexes := []

	for i in range(slots.size()):
		if slots[i] == null:
			empty_indexes.append(i)

	if empty_indexes.size() == 0:
		return

	var selected_index = empty_indexes[randi() % empty_indexes.size()]
	slots[selected_index] = event

func _place_director_appointment_in_random_empty_slot(slots: Array, day: int) -> void:
	var event = _get_director_appointment_event(day)

	if event == null:
		return

	var empty_indexes := []

	for i in range(slots.size()):
		if slots[i] == null:
			empty_indexes.append(i)

	if empty_indexes.size() == 0:
		return

	var selected_index = empty_indexes[randi() % empty_indexes.size()]
	slots[selected_index] = event
	
func _get_director_appointment_event(day: int):
	if GameManager.summoned_character == null:
		var fallback = get_available_events(day, "director_appointment")

		if fallback.size() > 0:
			return _pick_weighted_event(fallback)

		return null

	var character_id = GameManager.summoned_character
	var pool := []

	for event in get_available_events(day, "director_appointment"):
		if event.get("character", "") == character_id:
			pool.append(event)

	if pool.size() > 0:
		return _pick_weighted_event(pool)

	return _create_generic_appointment_event(character_id)
	
func get_next_event():
	if daily_plan.size() == 0:
		build_day_plan(GameManager.current_day)

	if daily_index >= daily_plan.size():
		return null

	var event = daily_plan[daily_index]
	daily_index += 1

	GameManager.mark_event_used(event["id"])

	return event


# =========================
# AGREGAR EVENTOS AL DÍA
# =========================

func _add_random_events(day: int, event_type: String, amount: int) -> void:
	var pool = get_available_events(day, event_type)

	for i in range(amount):
		if pool.size() == 0:
			break

		var event = _pick_weighted_event(pool)

		if event == null:
			break

		daily_plan.append(event)
		pool.erase(event)


func _add_director_appointment_event(day: int) -> void:
	if GameManager.summoned_character == null:
		var fallback = get_available_events(day, "director_appointment")

		if fallback.size() > 0:
			daily_plan.append(_pick_weighted_event(fallback))

		return

	var character_id = GameManager.summoned_character
	var pool = []

	for event in get_available_events(day, "director_appointment"):
		if event.get("character", "") == character_id:
			pool.append(event)

	if pool.size() > 0:
		daily_plan.append(_pick_weighted_event(pool))
		return

	var fallback_event = _create_generic_appointment_event(character_id)
	daily_plan.append(fallback_event)


func _create_generic_appointment_event(character_id: String) -> Dictionary:
	var character_data = GameManager.get_character_data(character_id)

	return {
		"id": "generic_appointment_" + character_id + "_day_" + str(GameManager.current_day),
		"title": "Cita del director",
		"description": character_data.get("name", "El personaje") + " entra a tu oficina. No estaba en la agenda pública, pero pediste verlo personalmente.",
		"character": character_id,
		"type": "director_appointment",
		"day": GameManager.current_day,
		"probability": 10,
		"unique": false,
		"requirements": {
			"money": 0,
			"innovation": 0,
			"workers": 0,
			"acceptance": 0
		},
		"required_flags": [],
		"blocked_flags": [],
		"option1": {
			"text": "Escuchar su reporte",
			"effects": {},
			"flags_add": [character_id + "_heard"],
			"flags_messages": {
				character_id + "_heard": "Escuchaste a " + character_data.get("name", character_id)
			},
			"trust_add": 1
		},
		"option2": {
			"text": "Mantener la reunión breve",
			"effects": {},
			"flags_add": [],
			"flags_messages": {},
			"trust_add": 0
		}
	}


# =========================
# FILTROS
# =========================

func get_available_events(day: int, event_type: String) -> Array:
	var available = []

	for event in events:
		if not _event_matches_day(event, day):
			continue

		if event.get("type", "normal") != event_type:
			continue

		if event.get("unique", true) and GameManager.has_event_been_used(event["id"]):
			continue

		if not _requirements_met(event):
			continue

		if not _required_flags_met(event):
			continue

		if _has_blocked_flags(event):
			continue

		if not _matches_priority(event):
			continue

		available.append(event)

	return available


func _event_matches_day(event: Dictionary, day: int) -> bool:
	if event.has("day"):
		return event["day"] == day

	if event.has("days"):
		return day in event["days"]

	return false


func _requirements_met(event: Dictionary) -> bool:
	var requirements = event.get("requirements", {})

	for stat_name in requirements.keys():
		if not GameManager.stats.has(stat_name):
			continue

		if GameManager.stats[stat_name] < requirements[stat_name]:
			return false

	return true


func _required_flags_met(event: Dictionary) -> bool:
	for flag in event.get("required_flags", []):
		if not GameManager.has_flag(flag):
			return false

	return true


func _has_blocked_flags(event: Dictionary) -> bool:
	for flag in event.get("blocked_flags", []):
		if GameManager.has_flag(flag):
			return true

	return false


func _matches_priority(event: Dictionary) -> bool:
	if GameManager.selected_priority == null:
		return true

	var tags = event.get("tags", [])

	if tags.has(GameManager.selected_priority):
		return true

	# No bloquea del todo; solo permite que existan eventos fuera de prioridad.
	# Si quieres forzar totalmente la prioridad, cambia esto a false.
	return true


# =========================
# SELECCIÓN POR PROBABILIDAD
# =========================

func _pick_weighted_event(pool: Array):
	if pool.size() == 0:
		return null

	var total_weight := 0

	for event in pool:
		total_weight += int(event.get("probability", 10))

	var roll = randi() % total_weight
	var current := 0

	for event in pool:
		current += int(event.get("probability", 10))

		if roll < current:
			return event

	return pool[0]
