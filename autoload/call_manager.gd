extends Node

var calls = []

var trust_levels = {
	"activista": 0,
	"agente": 0,
	"antiguo_director": 0,
	"cherry": 0,
	"cientifica": 0,
	"cliente": 0,
	"community_manager": 0,
	"conserje": 0,
	"contador": 0,
	"director_junta": 0,
	"hacker": 0,
	"ia_malvada": 0,
	"inversionista": 0,
	"medica": 0,
	"periodista": 0,
	"programador": 0,
	"rrhh": 0,
	"seguridad": 0,
	"tiempo": 0,
	"trabajador": 0
}

func _ready():
	load_calls()


func load_calls():
	var file = File.new()

	if not file.file_exists("res://data/calls.json"):
		push_error("No se encontró calls.json")
		return

	var error = file.open("res://data/calls.json", File.READ)
	if error != OK:
		push_error("No se pudo abrir calls.json")
		return

	var json_text = file.get_as_text()
	file.close()

	var parsed = JSON.parse(json_text)
	if parsed.error != OK:
		push_error("Error al parsear calls.json")
		return

	calls = parsed.result


func get_trust(character_id: String) -> int:
	return int(trust_levels.get(character_id, 0))


func set_trust(character_id: String, value: int):
	trust_levels[character_id] = clamp(value, 0, 3)


func add_trust(character_id: String, amount: int = 1):
	var current = get_trust(character_id)
	trust_levels[character_id] = clamp(current + amount, 0, 3)


func get_call_event(character_id: String):
	var call_data = _find_call_by_character(character_id)

	if call_data == null:
		return null

	var dialogue = _select_dialogue(call_data)

	if dialogue == null:
		return null

	return _dialogue_to_event(call_data, dialogue)


func _find_call_by_character(character_id: String):
	for call_data in calls:
		if call_data.get("character", "") == character_id:
			return call_data

	return null


func _select_dialogue(call_data: Dictionary):
	var character_id = call_data.get("character", "")
	var trust = get_trust(character_id)

	var valid_dialogues = []

	for dialogue in call_data.get("dialogues", []):
		var required_level = int(dialogue.get("required_level", 0))

		if required_level > trust:
			continue

		if not _has_required_flags(dialogue.get("required_flags", [])):
			continue

		valid_dialogues.append(dialogue)

	if valid_dialogues.empty():
		return _get_default_dialogue(call_data)

	valid_dialogues.sort_custom(self, "_sort_dialogues")

	return valid_dialogues[0]


func _sort_dialogues(a: Dictionary, b: Dictionary) -> bool:
	var a_level = int(a.get("required_level", 0))
	var b_level = int(b.get("required_level", 0))

	if a_level != b_level:
		return a_level > b_level

	var a_flags = a.get("required_flags", []).size()
	var b_flags = b.get("required_flags", []).size()

	if a_flags != b_flags:
		return a_flags > b_flags

	var a_priority = int(a.get("priority", 0))
	var b_priority = int(b.get("priority", 0))

	if a_priority != b_priority:
		return a_priority > b_priority

	return str(a.get("id", "")) > str(b.get("id", ""))


func _get_default_dialogue(call_data: Dictionary):
	for dialogue in call_data.get("dialogues", []):
		if int(dialogue.get("required_level", 0)) == 0 and dialogue.get("required_flags", []).empty():
			return dialogue

	return null


func _has_required_flags(required_flags: Array) -> bool:
	for flag in required_flags:
		if not GameManager.flags.has(flag):
			return false

	return true


func _dialogue_to_event(call_data: Dictionary, dialogue: Dictionary) -> Dictionary:
	var character_id = call_data.get("character", "")

	var options = dialogue.get("options", [])

	var option1 = {}
	var option2 = {}

	if options.size() > 0:
		option1 = _normalize_option(options[0])
	else:
		option1 = _normalize_option({
			"text": "Colgar",
			"flags_add": [],
			"flags_messages": {}
		})

	if options.size() > 1:
		option2 = _normalize_option(options[1])
	else:
		option2 = _normalize_option({
			"text": "Colgar",
			"flags_add": [],
			"flags_messages": {}
		})

	return {
		"id": str(call_data.get("id", "call")) + "::" + str(dialogue.get("id", "dialogue")),
		"type": "call",
		"character": character_id,
		"description": dialogue.get("text", ""),
		"option1": option1,
		"option2": option2
	}


func _normalize_option(option: Dictionary) -> Dictionary:
	return {
		"text": option.get("text", "Continuar"),
		"effects": option.get("effects", {}),
		"flags_add": option.get("flags_add", []),
		"flags_remove": option.get("flags_remove", []),
		"flags_messages": option.get("flags_messages", {}),
		"trust_add": option.get("trust_add", 0),
		"unlock_files": option.get("unlock_files", [])
	}


func apply_call_option(character_id: String, option: Dictionary):
	for flag in option.get("flags_add", []):
		GameManager.add_flag(flag)

	for flag in option.get("flags_remove", []):
		if GameManager.flags.has(flag):
			GameManager.flags.erase(flag)

	var trust_delta = int(option.get("trust_add", 0))
	if trust_delta != 0:
		add_trust(character_id, trust_delta)
