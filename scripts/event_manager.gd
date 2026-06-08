extends Node

var events = []
var characters = {
	"activista":         {"id": "activista",         "name": "Mara",              "role": "Activista Ambiental",       "texture": "res://assets/characters/activista.png"},
	"agente":            {"id": "agente",             "name": "Reeves",            "role": "Agente FTC",                "texture": "res://assets/characters/agente.png"},
	"antiguo_director":  {"id": "antiguo_director",   "name": "???",               "role": "Antiguo Director",          "texture": "res://assets/characters/antiguo_director.png"},
	"cherry":            {"id": "cherry",             "name": "Cherry",            "role": "Desarrollador",             "texture": "res://assets/characters/cherry.png"},
	"cientifica":        {"id": "cientifica",         "name": "Dra. Voss",         "role": "Científica de Datos",       "texture": "res://assets/characters/cientifica.png"},
	"cliente":           {"id": "cliente",            "name": "Harmon",            "role": "Cliente Corporativo",       "texture": "res://assets/characters/cliente.png"},
	"community_manager": {"id": "community_manager",  "name": "Carol",             "role": "Marketing",                 "texture": "res://assets/characters/community_manager.png"},
	"conserje":          {"id": "conserje",           "name": "Don Rubén",         "role": "Conserje",                  "texture": "res://assets/characters/conserje.png"},
	"contador":          {"id": "contador",           "name": "Ellis",             "role": "Contador",                  "texture": "res://assets/characters/contador.png"},
	"director_junta":    {"id": "director_junta",     "name": "???",               "role": "Director de Junta",         "texture": "res://assets/characters/junta.png"},
	"hacker":            {"id": "hacker",             "name": "Null",              "role": "Atacante Cibernético",      "texture": "res://assets/characters/hacker.png"},
	"ia_malvada":        {"id": "ia_malvada",         "name": "CORE",              "role": "IA Interna",                "texture": "res://assets/characters/ia_malvada.png"},
	"inversionista":     {"id": "inversionista",      "name": "???",               "role": "Inversionista",             "texture": "res://assets/characters/inversionista.png"},
	"medica":            {"id": "medica",             "name": "???",               "role": "Médica Corporativa",        "texture": "res://assets/characters/medica.png"},
	"periodista":        {"id": "periodista",         "name": "Sandra Veil",       "role": "Periodista — AXIS Network", "texture": "res://assets/characters/periodista.png"},
	"programador":       {"id": "programador",        "name": "Kevin",             "role": "Programador Senior",        "texture": "res://assets/characters/programador.png"},
	"rrhh":              {"id": "rrhh",               "name": "Claire",            "role": "Recursos Humanos",          "texture": "res://assets/characters/rrhh.png"},
	"seguridad":         {"id": "seguridad",          "name": "???",               "role": "Director de Seguridad",     "texture": "res://assets/characters/seguridad.png"},
	"tiempo":            {"id": "tiempo",             "name": "El Tiempo",         "role": "???",                       "texture": "res://assets/characters/tiempo.png"},
	"trabajador":        {"id": "trabajador",         "name": "????",              "role": "Empleado #348",             "texture": "res://assets/characters/trabajador.png"}
}

func get_character_texture(role: String):
	if characters.has(role):
		return load(characters[role]["texture"])
	return null

func get_character_data(role: String) -> Dictionary:
	if characters.has(role):
		return characters[role]
	return {}

func _ready():
	randomize()
	load_events()

func load_events():
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

var used_events = []

func get_random_event(turn: int = 1):
	var available = []
	for event in events:
		if not used_events.has(event["id"]):
			available.append(event)
	if available.size() == 0:
		return null

	# Fase 1: buscar evento con position fija para este turno
	for event in available:
		if event.get("position", -1) != turn:
			continue
		var meets_flags = true
		for flag in event.get("required_flags", []):
			if not GameManager.flags.has(flag):
				meets_flags = false
				break
		if meets_flags:
			used_events.append(event["id"])
			return event

	# Fase 2: pool aleatorio — excluir eventos con position fija y fuera de rango
	var pool = []
	for event in available:
		# Si tiene position fija, solo puede salir en ese turno exacto
		if event.has("position") and event["position"] >= 0:
			continue
		# Respetar min_turn / max_turn
		var min_t = event.get("min_turn", 1)
		var max_t = event.get("max_turn", 999)
		if turn < min_t or turn > max_t:
			continue
		pool.append(event)

	while pool.size() > 0:
		var idx = randi() % pool.size()
		var event = pool[idx]
		pool.remove(idx)
		var meets_flags = true
		for flag in event.get("required_flags", []):
			if not GameManager.flags.has(flag):
				meets_flags = false
				break
		if meets_flags:
			used_events.append(event["id"])
			return event

	return null
