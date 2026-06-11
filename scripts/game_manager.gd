extends Node

# =========================
# PROGRESO GENERAL
# =========================

signal stats_changed(stats)
signal game_over(reason)
var current_day: int = 1
var max_days: int = 10
var is_game_over := false

var events_per_day: int = 7
var events_completed_today: int = 0
var director_agenda_options := []

# =========================
# ESTADÍSTICAS
# =========================

var stats := {
	"money": 50,
	"innovation": 50,
	"workers": 50,
	"acceptance": 50
}

var min_stat: int = 0
var max_stat: int = 100


# =========================
# CONSUMIBLES DIARIOS
# =========================

var consumables := {
	"director_appointments": 1,
	"calls": 1
}

var consumables_used := {
	"director_appointments": 0,
	"calls": 0
}


# =========================
# FLAGS / HISTORIA
# =========================

var flags := {}
var used_events := []
var unlocked_files := []


# =========================
# AGENDA DEL DIRECTOR
# =========================

var summoned_character = null
var selected_priority = null


# =========================
# PERSONAJES
# =========================

var characters = {
	"activista": {
		"id": "activista",
		"name": "Mara Sol",
		"role": "Activista Ambiental",
		"texture": "res://assets/characters/activista.png",
		"appointment_cost": {"acceptance": -5},
		"tags": ["public_image", "ethics", "environment"]
	},

	"agente": {
		"id": "agente",
		"name": "Reeves",
		"role": "Agente Federal",
		"texture": "res://assets/characters/agente.png",
		"appointment_cost": {"acceptance": -10},
		"tags": ["government", "investigation", "security"]
	},

	"antiguo_director": {
		"id": "antiguo_director",
		"name": "Silas Veyr",
		"role": "Antiguo Director",
		"texture": "res://assets/characters/antiguo_director.png",
		"appointment_cost": {"money": -5},
		"tags": ["past", "nexus", "echo"]
	},

	"cherry": {
		"id": "cherry",
		"name": "Cherry",
		"role": "Desarrollador",
		"texture": "res://assets/characters/cherry.png",
		"appointment_cost": {"innovation": -5},
		"tags": ["tutorial", "development"]
	},

	"cientifica": {
		"id": "cientifica",
		"name": "Dra. Helena Voss",
		"role": "Científica de Datos",
		"texture": "res://assets/characters/cientifica.png",
		"appointment_cost": {"money": -10},
		"tags": ["research", "echo", "innovation"]
	},

	"cliente": {
		"id": "cliente",
		"name": "Harmon",
		"role": "Cliente Corporativo",
		"texture": "res://assets/characters/cliente.png",
		"appointment_cost": {"innovation": -5},
		"tags": ["money", "contract", "market"]
	},

	"community_manager": {
		"id": "community_manager",
		"name": "Vera Knox",
		"role": "Marketing",
		"texture": "res://assets/characters/community_manager.png",
		"appointment_cost": {"money": -5},
		"tags": ["acceptance", "marketing", "public_image"]
	},

	"conserje": {
		"id": "conserje",
		"name": "Don Rubén",
		"role": "Conserje",
		"texture": "res://assets/characters/conserje.png",
		"appointment_cost": {"money": -3},
		"tags": ["internal", "rumors", "workers"]
	},

	"contador": {
		"id": "contador",
		"name": "Ellis",
		"role": "Contador",
		"texture": "res://assets/characters/contador.png",
		"appointment_cost": {"acceptance": -5},
		"tags": ["money", "finance", "board"]
	},

	"director_junta": {
		"id": "director_junta",
		"name": "Eleanor Strake",
		"role": "Director de Junta",
		"texture": "res://assets/characters/junta.png",
		"appointment_cost": {"workers": -5},
		"tags": ["board", "money", "pressure"]
	},

	"hacker": {
		"id": "hacker",
		"name": "Null",
		"role": "Atacante Cibernético",
		"texture": "res://assets/characters/hacker.png",
		"appointment_cost": {"innovation": -10},
		"tags": ["security", "cyberattack", "echo"]
	},

	"ia_malvada": {
		"id": "ia_malvada",
		"name": "CORE",
		"role": "IA Interna",
		"texture": "res://assets/characters/ia_malvada.png",
		"appointment_cost": {},
		"tags": ["core", "echo", "ai"]
	},

	"inversionista": {
		"id": "inversionista",
		"name": "Victor Harlowe",
		"role": "Inversionista",
		"texture": "res://assets/characters/inversionista.png",
		"appointment_cost": {"workers": -5},
		"tags": ["money", "pressure", "board"]
	},

	"medica": {
		"id": "medica",
		"name": "Dra. Naomi Kess",
		"role": "Médica Corporativa",
		"texture": "res://assets/characters/medica.png",
		"appointment_cost": {"money": -5},
		"tags": ["health", "workers", "ethics"]
	},

	"periodista": {
		"id": "periodista",
		"name": "Sandra Veil",
		"role": "Periodista — AXIS Network",
		"texture": "res://assets/characters/periodista.png",
		"appointment_cost": {"innovation": -5},
		"tags": ["press", "acceptance", "public_image"]
	},

	"programador": {
		"id": "programador",
		"name": "Kevin",
		"role": "Programador Senior",
		"texture": "res://assets/characters/programador.png",
		"appointment_cost": {"innovation": -5},
		"tags": ["development", "bug", "echo"]
	},

	"rrhh": {
		"id": "rrhh",
		"name": "Claire",
		"role": "Recursos Humanos",
		"texture": "res://assets/characters/rrhh.png",
		"appointment_cost": {"money": -5},
		"tags": ["workers", "internal", "morale"]
	},

	"seguridad": {
		"id": "seguridad",
		"name": "Darius Flint",
		"role": "Director de Seguridad",
		"texture": "res://assets/characters/seguridad.png",
		"appointment_cost": {"workers": -5},
		"tags": ["security", "control", "surveillance"]
	},

	"tiempo": {
		"id": "tiempo",
		"name": "El Tiempo",
		"role": "???",
		"texture": "res://assets/characters/tiempo.png",
		"appointment_cost": {},
		"tags": ["unknown", "meta"]
	},

	"trabajador": {
		"id": "trabajador",
		"name": "#2847",
		"role": "Empleado",
		"texture": "res://assets/characters/trabajador.png",
		"appointment_cost": {"money": -5},
		"tags": ["workers", "internal", "labor"]
	},

	"disenadora": {
		"id": "disenadora",
		"name": "Iris Vale",
		"role": "Diseñadora",
		"texture": "res://assets/characters/disenadora.png",
		"appointment_cost": {"innovation": -5},
		"tags": ["design", "product", "acceptance"]
	},

	"mantenimiento": {
		"id": "mantenimiento",
		"name": "Bruno Kade",
		"role": "Mantenimiento",
		"texture": "res://assets/characters/mantenimiento.png",
		"appointment_cost": {"money": -5},
		"tags": ["infrastructure", "servers", "workers"]
	}
}


func _ready() -> void:
	randomize()
	start_day(1)


# =========================
# PERSONAJES
# =========================

func get_character_texture(character_id: String):
	if characters.has(character_id):
		return load(characters[character_id]["texture"])
	return null


func get_character_data(character_id: String) -> Dictionary:
	if characters.has(character_id):
		return characters[character_id]
	return {}


func get_character_appointment_cost(character_id: String) -> Dictionary:
	if not characters.has(character_id):
		return {}

	return characters[character_id].get("appointment_cost", {})

func build_director_agenda(day_data: Dictionary) -> void:
	director_agenda_options.clear()

	var agenda = day_data.get("director_agenda", {})

	var fixed_character = agenda.get("fixed_character", "")
	var random_characters = agenda.get("random_characters", [])
	var random_count = int(agenda.get("random_count", 2))

	if fixed_character != "" and characters.has(fixed_character):
		director_agenda_options.append(fixed_character)

	var pool := []

	for character_id in random_characters:
		if character_id == fixed_character:
			continue

		if not characters.has(character_id):
			continue

		pool.append(character_id)

	pool.shuffle()

	for i in range(random_count):
		if pool.size() == 0:
			break

		director_agenda_options.append(pool.pop_front())
		
func get_director_agenda_options() -> Array:
	return director_agenda_options
# =========================
# DÍAS
# =========================

func start_day(day: int) -> void:
	current_day = day
	events_completed_today = 0

	summoned_character = null
	selected_priority = null

	clear_daily_flags()
	reset_daily_consumables()

	emit_signal("stats_changed", stats)


func end_day() -> void:
	check_daily_collectible()

	if current_day >= max_days:
		end_game()
		return

	start_day(current_day + 1)


func complete_event() -> void:
	events_completed_today += 1

	if events_completed_today >= events_per_day:
		end_day()


# =========================
# CONSUMIBLES
# =========================

func reset_daily_consumables() -> void:
	consumables["director_appointments"] = 1
	consumables["calls"] = get_calls_for_day(current_day)

	consumables_used["director_appointments"] = 0
	consumables_used["calls"] = 0


func get_calls_for_day(day: int) -> int:
	if day >= 1 and day <= 3:
		return 1

	if day >= 4 and day <= 6:
		return 2

	if day >= 7 and day <= 10:
		return 3

	return 1


func can_use_consumable(consumable_name: String) -> bool:
	if not consumables.has(consumable_name):
		return false

	if not consumables_used.has(consumable_name):
		return false

	return consumables_used[consumable_name] < consumables[consumable_name]


func use_consumable(consumable_name: String) -> bool:
	if not can_use_consumable(consumable_name):
		return false

	consumables_used[consumable_name] += 1
	return true


# =========================
# AGENDA DEL DIRECTOR
# =========================
func summon_character(character_id: String) -> bool:
	if summoned_character != null:
		return false

	if not characters.has(character_id):
		return false

	if not director_agenda_options.has(character_id):
		return false

	if not can_use_consumable("director_appointments"):
		return false

	var cost = get_character_appointment_cost(character_id)

	if not can_pay_cost(cost):
		return false

	use_consumable("director_appointments")
	apply_effects(cost)

	summoned_character = character_id
	add_flag(character_id + "_summoned_today")

	return true


func set_priority(priority: String) -> void:
	selected_priority = priority


# =========================
# STATS
# =========================

func apply_effects(effects: Dictionary) -> bool:
	if is_game_over:
		return false

	for stat_name in effects.keys():
		if not stats.has(stat_name):
			continue

		stats[stat_name] += effects[stat_name]
		stats[stat_name] = clamp(stats[stat_name], min_stat, max_stat)

	emit_signal("stats_changed", stats)

	return check_game_over()


func can_pay_cost(cost: Dictionary) -> bool:
	for stat_name in cost.keys():
		if not stats.has(stat_name):
			continue

		var final_value = stats[stat_name] + cost[stat_name]

		if final_value <= min_stat:
			return false

		if final_value >= max_stat:
			return false

	return true

func check_game_over() -> bool:
	for stat_name in stats.keys():
		if stats[stat_name] <= min_stat:
			game_over(stat_name)
			return false

		if stats[stat_name] >= max_stat:
			game_over(stat_name)
			return false

	return true


# =========================
# FLAGS
# =========================

func add_flag(flag_name: String) -> void:
	flags[flag_name] = true


func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name) and flags[flag_name] == true


func remove_flag(flag_name: String) -> void:
	if flags.has(flag_name):
		flags.erase(flag_name)


func clear_daily_flags() -> void:
	var to_remove := []

	for flag_name in flags.keys():
		if flag_name.ends_with("_today"):
			to_remove.append(flag_name)

	for flag_name in to_remove:
		flags.erase(flag_name)


# =========================
# EVENTOS USADOS
# =========================

func mark_event_used(event_id: String) -> void:
	if not used_events.has(event_id):
		used_events.append(event_id)


func has_event_been_used(event_id: String) -> bool:
	return used_events.has(event_id)


# =========================
# ARCHIVOS
# =========================

func unlock_file(file_id: String) -> void:
	if not unlocked_files.has(file_id):
		unlocked_files.append(file_id)


func has_file(file_id: String) -> bool:
	return unlocked_files.has(file_id)


func check_daily_collectible() -> void:
	pass

func get_calls_left() -> int:
	return consumables["calls"] - consumables_used["calls"]


func can_call() -> bool:
	return get_calls_left() > 0


func use_call() -> bool:
	if not can_call():
		return false

	consumables_used["calls"] += 1
	return true

# =========================
# FINAL
# =========================

func game_over(reason: String) -> void:
	if is_game_over:
		return

	is_game_over = true
	emit_signal("game_over", reason)

func end_game() -> void:
	print("Fin del juego")
