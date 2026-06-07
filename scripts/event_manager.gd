extends Node

var events = []

var characters = {
	"activista":   {"name": "Mara",         "role": "Activista Ambiental",      "texture": "res://assets/characters/activista.png"},
	"agente":      {"name": "Reeves",        "role": "Agente FTC",               "texture": "res://assets/characters/agente.png"},
	"cherry":      {"name": "Cherry", "role":"Desarrollador", "texture":"res://assets/characters/cherry.png"},
	"community_manager": {"name":"Carol", "role": "Marketing", "texture":"res://assets/characters/community_manager.png"},
	"cientifica":  {"name": "Dra. Voss",     "role": "Científica de Datos",      "texture": "res://assets/characters/cientifica.png"},
	"cliente":     {"name": "Harmon",        "role": "Cliente Corporativo",      "texture": "res://assets/characters/cliente.png"},
	"conserje":    {"name": "Don Rubén",     "role": "Conserje",                 "texture": "res://assets/characters/conserje.png"},
	"contador":    {"name": "Ellis",         "role": "Contador",                 "texture": "res://assets/characters/contador.png"},
	"hacker":      {"name": "Null",          "role": "Atacante Cibernético",     "texture": "res://assets/characters/hacker.png"},
	"ia_malvada":  {"name": "CORE",          "role": "IA Interna",               "texture": "res://assets/characters/ia_malvada.png"},
	"periodista":  {"name": "Sandra Veil",   "role": "Periodista — AXIS Network","texture": "res://assets/characters/periodista.png"},
	"programador": {"name": "Kevin",         "role": "Programador Senior",       "texture": "res://assets/characters/programador.png"},
	"rrhh":        {"name": "Claire",        "role": "Recursos Humanos",         "texture": "res://assets/characters/rrhh.png"},
	"tiempo":      {"name":"El tiempo", "role": "???", "texture":"res://assets/characters/tiempo.png"},
	"trabajador":  {"name": "????",          "role": "Empleado #348",           "texture": "res://assets/characters/trabajador.png"}
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
	# Descartar eventos ya usados
	var available = []
	for event in events:
		if not used_events.has(event["id"]):
			available.append(event)
	
	if available.size() == 0:
		return null
	
	# Buscar evento fijo para este turno que cumpla flags
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
	# Ningún evento fijo coincidió, buscar aleatorio que cumpla flags
	var pool = available.duplicate()
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
