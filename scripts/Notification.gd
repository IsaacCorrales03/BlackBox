extends Control

onready var label = $Panel/Label

func show_message(text: String, color: Color = Color("#B8D8E8")):
	label.text = text
	label.add_color_override("font_color", color)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# entrada
	modulate.a = 0
	rect_position.x += 30
	tween.tween_property(self, "modulate:a", 1.0, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rect_position:x", rect_position.x - 30, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	yield(get_tree().create_timer(2.5), "timeout")
	
	# salida
	var tween2 = get_tree().create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(self, "modulate:a", 0.0, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween2.tween_property(self, "rect_position:x", rect_position.x + 20, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	yield(tween2, "finished")
	queue_free()
