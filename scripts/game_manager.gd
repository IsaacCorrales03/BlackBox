extends Node

signal stats_changed(stats)
signal game_over(reason)

var stats = {
	"money": 50,
	"innovation": 50,
	"workers": 50,
	"acceptance": 50
}
var flags = []

func add_flag(flag: String):
	if not flags.has(flag):
		flags.append(flag)

func apply_effects(effects) -> bool:
	for stat in effects:
		if stats.has(stat):
			var new_val = stats[stat] + effects[stat]
			if new_val <= 0:
				stats[stat] = 0
				emit_signal("stats_changed", stats)
				emit_signal("game_over", stat)
				return false
			stats[stat] = clamp(new_val, 0, 100)
	emit_signal("stats_changed", stats)
	return true

func reset():
	stats = {
		"money": 50,
		"innovation": 50,
		"workers": 50,
		"acceptance": 50
	}
	emit_signal("stats_changed", stats)
func _ready():
	Input.set_custom_mouse_cursor(preload("res://assets/cursor.png"))
