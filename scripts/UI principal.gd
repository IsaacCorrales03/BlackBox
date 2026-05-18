extends Control

onready var dilema_text_label = $Dilema_text
onready var opcion_a_text = $opcion_a/texto
onready var opcion_b_text = $opcion_b/texto
var descripcion = """El sistema de la ciudad falla en el peor momento. 
Si lo apagas para arreglarlo, se detienen servicios básicos durante horas: transporte, electricidad y comunicaciones.
Si lo dejas encendido, todo sigue funcionando, pero queda una falla abierta que podría ser usada para atacar el sistema en cualquier momento."""
var opcion_a = "Repararlo"
var opcion_b = "Ignorarlo"
var writing = false
func _ready():
	write_description()
	write_options()

func write_buttons():
	pass

func write_description():
	if writing:
		return
	writing = true
	dilema_text_label.text = ""

	for i in range(descripcion.length()):
		dilema_text_label.text += descripcion[i]
		yield(get_tree().create_timer(0.01), "timeout")

	writing = false
	
func write_options():
	opcion_a_text.text = opcion_a
	opcion_b_text.text = opcion_b
