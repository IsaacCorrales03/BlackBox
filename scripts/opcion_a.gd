extends Button

export var border_color = Color("#00AAFF")
export var bg_color = Color("#060A0E")
export var cut = 10
var is_hovered = false
var is_pressed_down = false

# animación
var anim_t = 0.0
var anim_target = 0.0
var scan_offset = 0.0

func _ready():
	connect("mouse_entered", self, "_on_hover")
	connect("mouse_exited", self, "_on_exit")
	connect("button_down", self, "_on_down")
	connect("button_up", self, "_on_up")
	set_process(true)

func _on_hover():
	is_hovered = true
	anim_target = 1.0

func _on_exit():
	is_hovered = false
	is_pressed_down = false
	anim_target = 0.0

func _on_down():
	is_pressed_down = true
	var sfx = $"../../button_press"
	if not sfx.playing:
		sfx.play()
	update()
func _on_up():
	is_pressed_down = false
	update()
	# no stopear — deja que termine solo
func _process(delta):
	# suaviza transición hover
	anim_t = lerp(anim_t, anim_target, delta * 10.0)

	# scanline animado solo en hover
	if is_hovered or anim_t > 0.01:
		scan_offset = fmod(scan_offset + delta * 80.0, rect_size.y)

	update()

func _draw():
	var w = rect_size.x
	var h = rect_size.y
	var c = cut
	var t = anim_t

	var points = PoolVector2Array([
		Vector2(c, 0),
		Vector2(w - c, 0),
		Vector2(w, c),
		Vector2(w, h - c),
		Vector2(w - c, h),
		Vector2(c, h),
		Vector2(0, h - c),
		Vector2(0, c)
	])

	# fondo base
	var fill = bg_color
	if is_pressed_down:
		fill = border_color.darkened(0.3)
		fill.a = 0.35
	else:
		var hover_fill = border_color
		hover_fill.a = 0.12 * t
		fill = bg_color
		draw_colored_polygon(points, fill)
		fill = hover_fill
	draw_colored_polygon(points, fill)

	# scanline sutil en hover
	if t > 0.01 and not is_pressed_down:
		var scan_color = border_color
		scan_color.a = 0.06 * t
		for i in range(3):
			var sy = fmod(scan_offset + i * 30.0, h)
			draw_line(Vector2(c, sy), Vector2(w - c, sy), scan_color, 1.0)

	# borde
	var bcol = border_color
	var bwidth = 1.5
	if is_pressed_down:
		bcol = Color.white
		bcol.a = 0.9
		bwidth = 2.0
	else:
		bcol.a = lerp(0.6, 1.0, t)
		bwidth = lerp(1.5, 2.5, t)

	for i in range(points.size()):
		var a = points[i]
		var b = points[(i + 1) % points.size()]
		draw_line(a, b, bcol, bwidth)

	# línea interior paralela al borde, solo en hover
	if t > 0.01:
		var inner_color = border_color
		inner_color.a = 0.2 * t
		var pad = 3.0
		var inner = PoolVector2Array([
			Vector2(c + pad, pad),
			Vector2(w - c - pad, pad),
			Vector2(w - pad, c + pad),
			Vector2(w - pad, h - c - pad),
			Vector2(w - c - pad, h - pad),
			Vector2(c + pad, h - pad),
			Vector2(pad, h - c - pad),
			Vector2(pad, c + pad)
		])
		for i in range(inner.size()):
			var a = inner[i]
			var b = inner[(i + 1) % inner.size()]
			draw_line(a, b, inner_color, 1.0)

	# flash en pressed
	if is_pressed_down:
		var flash = Color.white
		flash.a = 0.08
		draw_colored_polygon(points, flash)
