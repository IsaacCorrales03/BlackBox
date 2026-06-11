# BLACKBOX EXEC
### Game Design Document
`Godot 3 · GDScript · Reigns-style`

---

> *Año 2089. Las megacorporaciones reemplazaron a los gobiernos.*
> *Tú eres el Director Ejecutivo de Nexus Industries. Tu objetivo parece simple: mantener Nexus funcionando.*
> *El problema es que Nexus no es solo una empresa.*

---

## 01. PREMISA

El jugador asume el rol de Director Ejecutivo de **Nexus Industries**, una corporación tecnológica especializada en inteligencia artificial, implantes neuronales, automatización corporativa y sistemas de análisis predictivo.

El objetivo aparente es mantener la corporación operativa. El objetivo real se revela gradualmente: Nexus oculta el **Proyecto ECHO**, una infraestructura capaz de copiar, almacenar y manipular conciencias humanas.

La jugabilidad base toma inspiración de *Reigns*: decisiones binarias, consecuencias estadísticas y rutas narrativas condicionadas por flags.

---

## 02. ESTADÍSTICAS

Cualquier estadística en 0 termina la partida. Opcionalmente, también puede existir derrota si una estadística llega a 100 y queda “fuera de control”.

| STAT | DESCRIPCIÓN | SI LLEGA A 0 |
|---|---|---|
| **Economía** (`money`) | Recursos financieros corporativos | Bancarrota → Fin de partida |
| **Aceptación** (`acceptance`) | Opinión pública, prensa y reputación | Protestas masivas → Intervención externa |
| **Empleados** (`workers`) | Moral, productividad y lealtad interna | Huelgas, sabotajes, colapso operativo |
| **Innovación** (`innovation`) | Capacidad tecnológica y científica | Nexus queda obsoleta |

### Reglas de balance

- Las decisiones no deben tener una opción objetivamente correcta.
- Cada opción debe beneficiar algo y dañar algo.
- Las estadísticas deben forzar sacrificios.
- El jugador debe sentir que dirige una empresa en deterioro, no que responde cartas aisladas.

---

## 03. ESTRUCTURA PRINCIPAL: DÍAS

El sistema anterior por turnos se reemplaza por una estructura basada en **días narrativos**.

Cada día tiene una identidad propia, un bloque de eventos, llamadas disponibles, una cita del director y posibles archivos desbloqueables.

### Estructura base de un día

```text
Día X
├── 4 eventos normales
├── 1 evento de historia
├── 1 evento condicional
├── 1 evento de cita del director
├── llamadas disponibles
└── archivo coleccionable posible
```

### Distribución fija

| Tipo de evento | Cantidad diaria | Función |
|---|---:|---|
| `normal` | 4 | Gestión corporativa, stats, dilemas recurrentes |
| `story` | 1 | Avance narrativo principal |
| `conditional` | 1 | Bifurcación de flags o rutas |
| `director_appointment` | 1 | Cita forzada con un personaje elegido |
| **Total** | **7** | Eventos jugables diarios |

### Posición del evento de historia

El evento de historia nunca aparece al inicio del día.

Regla:

```text
Evento de historia:
- Puede aparecer en posición 5, 6 o 7.
- Nunca puede aparecer en posición 1, 2, 3 o 4.
```

Esto mantiene el ritmo:

```text
1-4: administración, presión, contexto
5-7: giro narrativo o tensión principal del día
```

---

## 04. MECÁNICAS PRINCIPALES

### 04.1 Decisiones binarias

Cada evento presenta dos opciones.

Cada opción puede:

- modificar estadísticas
- agregar flags
- remover flags
- aumentar o reducir confianza
- desbloquear archivos
- abrir o debilitar rutas narrativas

Ejemplo de opción:

```json
{
  "text": "Investígalo en silencio",
  "effects": {
    "money": -5,
    "innovation": 5,
    "workers": -5,
    "acceptance": 5
  },
  "flags_add": [
    "kevin_trust_you",
    "vulnerability_investigation_started",
    "echo_path_open"
  ],
  "flags_messages": {
    "kevin_trust_you": "Kevin confía más en ti.",
    "vulnerability_investigation_started": "Kevin empezó a investigar la anomalía.",
    "echo_path_open": "Una ruta oculta ha comenzado."
  },
  "trust_add": 1
}
```

---

### 04.2 Llamadas

Las llamadas son una mecánica secundaria de investigación narrativa.

Reglas:

- Las llamadas **no consumen eventos diarios**.
- Las llamadas **vuelven al evento normal previo** al colgar.
- Las llamadas consumen un recurso diario.
- Las llamadas pueden avanzar la historia solo por ocurrir.
- Las opciones dentro de una llamada matizan la ruta, no deberían bloquear finales por una única elección específica.

#### Llamadas disponibles por día

| Días | Llamadas disponibles |
|---|---:|
| 1-3 | 1 |
| 4-6 | 2 |
| 7-10 | 3 |

#### Flujo de llamada

```text
Click en contacto
↓
¿Quedan llamadas disponibles?
↓
¿Existe evento de llamada para ese contacto?
↓
Consume 1 llamada
↓
Muestra llamada
↓
Procesa diálogo / flags / efectos
↓
Cuelga
↓
Regresa al evento previo
```

#### Llamadas encadenadas

Una misma llamada puede dividirse en varios bloques cortos mediante:

```json
"next_dialogue": "id_del_siguiente_dialogo",
"end_call": false
```

El último bloque termina con:

```json
"end_call": true
```

Esto permite que una llamada se sienta como conversación sin gastar varias llamadas.

#### Flags automáticas al iniciar diálogo

Las llamadas pueden activar flags apenas inicia un bloque:

```json
"flags_on_start": [
  "kevin_day1_anomaly_discussed",
  "act1_vulnerability_thread_open"
],
"flags_messages_on_start": {
  "kevin_day1_anomaly_discussed": "Kevin empezó a explicarte la anomalía.",
  "act1_vulnerability_thread_open": "La línea de investigación interna quedó abierta."
}
```

Esto evita que el avance dependa de escoger una opción exacta.

---

### 04.3 Cita del director

Cada día permite citar **solo 1 personaje**.

Reglas:

- Solo puede citarse 1 personaje por día.
- Citar consume el recurso `director_appointments`.
- Citar puede tener costo estadístico.
- El personaje citado aparece obligatoriamente en el evento `director_appointment`.
- La cita es más fuerte que una llamada: fuerza presencia narrativa.

Ejemplo:

```text
Citar a Kevin
Costo: -5 innovación
Efecto: Kevin aparece sí o sí en la cita del director
Flag: programador_summoned_today
```

### Costos de cita por personaje

| Personaje | Costo sugerido | Justificación |
|---|---:|---|
| Trabajador / #2847 | `money -5` | Escucharlo implica recursos o concesiones |
| Claire / RRHH | `money -5` | Gestión interna consume presupuesto |
| Ellis / Contador | `acceptance -5` | Medidas financieras dañan imagen |
| Kevin / Programador | `innovation -5` | Lo apartas del desarrollo normal |
| Seguridad / Darius Flint | `workers -5` | Su presencia incomoda al personal |
| Sandra Veil / Periodista | `innovation -5` | Atender prensa distrae desarrollo |
| Reeves / Federal | `acceptance -10` | La empresa queda bajo sospecha |
| Dra. Voss / Científica | `money -10` | Investigación avanzada cuesta recursos |
| Inversionista | `workers -5` | Presiona productividad contra empleados |
| Cliente | `innovation -5` | Adaptarse al cliente limita experimentación |

---

### 04.4 Agenda del director

La agenda no muestra todos los personajes.

Cada día se genera una pool reducida:

```text
Agenda del director:
- 1 personaje fijo narrativo
- 2 personajes aleatorios
- el jugador elige 1
```

Ejemplo Día 1:

```json
"director_agenda": {
  "fixed_character": "cherry",
  "random_characters": [
    "contador",
    "rrhh",
    "community_manager",
    "programador",
    "mantenimiento"
  ],
  "random_count": 2
}
```

Esto evita que el jugador optimice siempre con el mismo personaje y permite control narrativo.

---

### 04.5 Archivos coleccionables

Los archivos son una mecánica terciaria de investigación.

Reglas:

- Cada día puede tener 1 archivo posible.
- No siempre se obtiene automáticamente.
- Puede depender de flags, llamadas o decisiones.
- Algunos archivos son perdibles (`missable`).
- Los archivos cuentan la historia oculta de Nexus y Proyecto ECHO.

Ejemplo:

```json
"collectible": {
  "id": "archivo_echo_03",
  "title": "Registro ECHO-03",
  "required_flags": [
    "kevin_day1_anomaly_discussed",
    "echo_logs_saved"
  ],
  "missable": true
}
```

---

## 05. ESTRUCTURA DE EVENTOS JSON

Los eventos ya no usan `min_turn`, `max_turn` ni `position`.

La estructura nueva usa:

- `day` o `days`
- `type`
- `tags`
- `unique`
- `required_flags`
- `blocked_flags`

### Tipos de evento

| Tipo | Uso |
|---|---|
| `normal` | Dilemas corporativos diarios |
| `story` | Evento narrativo principal del día |
| `conditional` | Evento que bifurca flags o rutas |
| `director_appointment` | Cita del director |
| `call` | Evento temporal de llamada |

### Ejemplo base

```json
{
  "id": "day1_normal_presupuesto_inicial",
  "title": "Presupuesto inicial",
  "description": "Director, el presupuesto de arranque está ajustado...",
  "character": "contador",
  "type": "normal",
  "day": 1,
  "tags": ["money", "workers"],
  "probability": 10,
  "unique": true,
  "requirements": {
    "money": 0,
    "innovation": 0,
    "workers": 0,
    "acceptance": 0
  },
  "required_flags": [],
  "blocked_flags": [],
  "option1": {
    "text": "Recortar gastos",
    "effects": {
      "money": 10,
      "workers": -5,
      "innovation": -5
    },
    "flags_add": [],
    "flags_messages": {},
    "trust_add": 0
  },
  "option2": {
    "text": "Liberar fondos",
    "effects": {
      "money": -10,
      "workers": 5,
      "innovation": 5
    },
    "flags_add": [],
    "flags_messages": {},
    "trust_add": 0
  }
}
```

---

## 06. ESTRUCTURA NARRATIVA POR FASES

La estructura anterior por turnos se compacta en días.

### FASE 1 — LA CORPORACIÓN / PRIMERA GRIETA `[Días 1–4]`

La partida parece un simulador corporativo. Eventos giran alrededor de presupuestos, marketing, empleados, infraestructura y clientes.

Pero aparecen anomalías:

- módulos que fallan sin conexión aparente
- procesos internos sin usuario asignado
- logs que podrían ser limpiados por Seguridad
- archivos antiguos
- contactos que saben más de lo que dicen

#### Día 1 — Primer día en Nexus

Objetivo narrativo:

```text
Plantar la primera grieta.
```

El evento de historia debe ser Kevin reportando una anomalía. No debe revelar ECHO todavía.

Señales permitidas:

- proceso interno viejo
- logs raros
- accesos no asociados a usuarios actuales
- Seguridad podría cerrar el incidente y borrar rastros

Señales que NO deben aparecer todavía:

- Proyecto ECHO explícito
- NULL
- sujetos de prueba
- conciencias copiadas
- conspiración abierta

#### Día 2 — Vulnerabilidad

Si Kevin fue autorizado y se le llama, puede ampliar la anomalía. Se prepara la posible aparición de Null.

#### Día 3 — Archivos internos

Don Rubén puede dejar archivos secretos. Se desbloquea la lógica de archivos ocultos.

#### Día 4 — Credenciales / cierre de acto

La ruta puede involucrar a Null, Voss, Seguridad o Kevin para conseguir credenciales. Cierra el Acto 1 con la investigación activa o debilitada.

---

### FASE 2 — LA CONSPIRACIÓN `[Días 5–7]`

Las anomalías comienzan a conectarse. Aparecen filtraciones, archivos clasificados, registros eliminados y mensajes anónimos.

El jugador descubre referencias al **Proyecto ECHO** — oficialmente cancelado hace años, pero activo en infraestructura y presupuesto.

Mensajes del Director Anterior comienzan a aparecer:

```text
"NO CONFÍES EN LOS ARCHIVOS OFICIALES"
"YO FUI DIRECTOR ANTES QUE TÚ"
"NO DEJES QUE TE COPIEN"
```

Evento final de fase:

```text
El jugador descubre parcialmente la verdad:
ECHO es tecnología capaz de copiar y almacenar conciencias humanas.
```

---

### FASE 3 — LA VERDAD `[Días 8–10]`

Todas las decisiones acumuladas empiezan a cerrar rutas.

El jugador descubre:

- ECHO nunca fue cancelado
- existen miles de conciencias almacenadas
- directivos históricos continúan existiendo digitalmente
- Silas Veyr sigue activo dentro del sistema
- la Junta conoce o participa en la continuidad de ECHO

El jugador debe decidir el futuro de ECHO.

---

## 07. DÍA 1 — CONTENIDO BASE

### 4 eventos normales

1. **Presupuesto inicial** — Ellis / Contador  
   Economía vs bienestar interno.

2. **Equipo cansado** — Claire / RRHH  
   Productividad vs moral de empleados.

3. **Demo inestable** — Kevin / Programador  
   Mostrar avance rápido vs proteger calidad técnica.

4. **Mensaje público** — Vera Knox / Marketing  
   Prometer una nueva era vs comunicación prudente.

### Evento de historia

**Anomalía en el servicio** — Kevin

Función:

```text
Kevin descubre que un fallo no parece un bug común.
El jugador decide si Kevin investiga o Seguridad toma el incidente.
```

Flags principales:

| Flag | Uso |
|---|---|
| `kevin_trust_you` | Permite conversación útil con Kevin |
| `vulnerability_investigation_started` | Abre investigación de vulnerabilidad |
| `echo_path_open` | Mantiene abierta la ruta oculta |
| `kevin_ignored` | Reduce relación con Kevin |
| `security_took_vulnerability` | Seguridad controla el incidente |
| `echo_path_weakened` | La ruta ECHO queda más difícil |

### Evento condicional

**Primer reporte interno** — Ellis

Opciones:

- reporte financiero → `day1_financial_report`
- diagnóstico interno → `day1_internal_diagnosis`

### Cita del director

Recomendación Día 1:

```text
Personaje fijo: Cherry
Aleatorios: Ellis, Claire, Vera, Kevin, Bruno
```

Cherry funciona como tutorial diegético del sistema de llamadas/contactos.

---

## 08. PERSONAJES

### Elenco principal

| ID | PERSONAJE | ROL / NOTAS |
|---|---|---|
| `cherry` | **Cherry** | Tutorial y guía inicial. Punto de entrada del jugador. |
| `rrhh` | **Claire** | Recursos Humanos. Bienestar, despidos, presión laboral. |
| `contador` | **Ellis** | Finanzas, presupuestos, reportes e inversionistas. |
| `cliente` | **Harmon** | Cliente corporativo. Contratos y presión de mercado. |
| `community_manager` | **Vera Knox** | Marketing, aceptación pública y crisis mediáticas. |
| `trabajador` | **#2847** | Voz anónima de empleados. Deshumanización laboral. |
| `programador` | **Kevin** | Sistemas, bugs, logs y primera grieta técnica. |
| `disenadora` | **Iris Vale** | Producto, identidad, innovación y aceptación. |
| `cientifica` | **Dra. Helena Voss** | Investigación avanzada. Clave para ECHO. |
| `mantenimiento` | **Bruno Kade** | Infraestructura y señales técnicas extrañas. |
| `conserje` | **Don Rubén** | Secretos internos, archivos y observaciones. |
| `periodista` | **Sandra Veil** | Prensa, filtraciones y presión externa. |
| `activista` | **Mara Sol** | Presión social, ética y ambiente. |
| `hacker` | **Null** | Intrusión, filtraciones y acceso a datos ocultos. |
| `agente` | **Reeves** | Investigación federal. Presión legal. |
| `ia_malvada` | **CORE** | IA interna. Antagonista progresivo. |
| `antiguo_director` | **Silas Veyr** | Director anterior, posible conciencia digital. |
| `inversionista` | **Victor Harlowe** | Accionistas y expansión agresiva. |
| `director_junta` | **Eleanor Strake** | Junta Directiva. Autoridad ejecutiva. |
| `medica` | **Dra. Naomi Kess** | Implantes, salud laboral y ética biomédica. |
| `seguridad` | **Darius Flint** | Vigilancia, seguridad y control interno. |
| `tiempo` | **El Tiempo** | Sistema narrativo/meta de deterioro y plazos. |

---

## 09. RUTA: DESTAPAMOS ECHO

Final de investigación. Requiere construir red de aliados y evidencias.

### Personajes clave

```text
Reeves
Null
Mara
Sandra
Don Rubén
```

No aparecen todos al inicio. Se integran progresivamente.

### Principio de diseño

```text
La ruta no debe depender de escoger una opción exacta una única vez.
La ruta debe depender de acumular señales, llamadas, confianza y archivos.
```

Acciones que abren o fortalecen la ruta:

- autorizar a Kevin
- llamar a Kevin sobre la anomalía
- guardar logs
- escuchar a Don Rubén
- contactar a Null sin denunciar inmediatamente
- hablar con Voss sin confrontarla demasiado pronto
- conseguir credenciales por Seguridad o rutas alternativas
- filtrar información a Sandra o Reeves en el momento adecuado

Acciones que debilitan la ruta:

- entregar todo a Seguridad demasiado pronto
- ignorar a Kevin
- cerrar la investigación
- denunciar a Null en el primer contacto
- destruir o no conservar archivos

---

## 10. ARQUITECTURA TÉCNICA

### Stack

- Motor: Godot 3.x
- Lenguaje: GDScript
- Resolución: 1024×512
- Layout: dos columnas:
  - izquierda: diálogo y opciones
  - derecha: estadísticas

---

### `GameManager.gd`

Autoload central de estado global.

Responsabilidades:

- día actual
- estadísticas
- consumibles diarios
- flags
- eventos usados
- archivos desbloqueados
- personaje citado
- prioridad seleccionada
- agenda del director
- datos de personajes
- señales de game over y stats

Campos principales:

```gdscript
var current_day: int = 1
var max_days: int = 10

var events_per_day: int = 7
var events_completed_today: int = 0

var stats := {
    "money": 50,
    "innovation": 50,
    "workers": 50,
    "acceptance": 50
}

var consumables := {
    "director_appointments": 1,
    "calls": 1
}

var consumables_used := {
    "director_appointments": 0,
    "calls": 0
}

var flags := {}
var used_events := []
var unlocked_files := []

var summoned_character = null
var selected_priority = null
var director_agenda_options := []
```

Señales:

```gdscript
signal stats_changed(stats)
signal game_over(reason)
```

Funciones clave:

```gdscript
start_day(day)
end_day()
complete_event()

reset_daily_consumables()
get_calls_for_day(day)
get_calls_left()
can_call()
use_call()

summon_character(character_id)
build_director_agenda(day_data)

apply_effects(effects)
can_pay_cost(cost)

add_flag(flag_name)
has_flag(flag_name)
remove_flag(flag_name)
clear_daily_flags()

unlock_file(file_id)
has_file(file_id)
```

---

### `EventManager.gd`

Encargado de cargar eventos y construir el plan diario.

Responsabilidades:

- cargar `events.json`
- construir `daily_plan`
- aplicar filtros de día/tipo/flags/requisitos
- respetar la posición tardía del evento de historia
- devolver eventos con `get_next_event()`

No debe manejar personajes.

Variables clave:

```gdscript
var events = []

var daily_plan := []
var daily_index := 0
var planned_day := -1

const EVENTS_PER_DAY := 7
const STORY_MIN_POSITION := 5
const STORY_MAX_POSITION := 7
```

Funciones clave:

```gdscript
load_events()
build_day_plan(day)
get_next_event()

get_available_events(day, event_type)
_event_matches_day(event, day)
_requirements_met(event)
_required_flags_met(event)
_has_blocked_flags(event)
_pick_weighted_event(pool)
```

Regla importante:

```gdscript
# No usar:
EventManager.get_random_event(turn)

# Usar:
EventManager.get_next_event()
```

---

### `CallManager.gd`

Encargado de cargar llamadas, confianza y diálogos encadenados.

Responsabilidades:

- cargar `calls.json`
- almacenar niveles de confianza por personaje
- elegir el diálogo válido de mayor prioridad
- soportar `required_flags` y `blocked_flags`
- convertir diálogos en eventos temporales tipo `call`
- resolver `next_dialogue`

Funciones clave:

```gdscript
load_calls()

get_trust(character_id)
set_trust(character_id, value)
add_trust(character_id, amount)

get_call_event(character_id)
get_dialogue_event(character_id, dialogue_id)

_find_call_by_character(character_id)
_select_dialogue(call_data)
_dialogue_to_event(call_data, dialogue)
_normalize_option(option)

apply_call_option(character_id, option)
```

`_normalize_option()` debe conservar:

```gdscript
"next_dialogue": option.get("next_dialogue", ""),
"end_call": option.get("end_call", true)
```

---

### `DilemmaUI.gd`

Responsabilidades:

- mostrar evento actual
- procesar botones
- typewriter
- barras de stats
- panel de contactos
- panel de archivos
- llamadas
- notificaciones

Reglas nuevas:

```text
Las decisiones normales:
- aplican efectos
- procesan flags
- desbloquean archivos
- registran contacto
- llaman GameManager.complete_event()
- cargan el siguiente evento

Las llamadas:
- revisan GameManager.can_call()
- solo consumen llamada si existe evento de llamada
- no avanzan el día
- soportan next_dialogue
- al colgar restauran el evento previo
```

No usar:

```gdscript
turn += 1
EventManager.get_random_event(turn)
EventManager.get_character_data(role)
```

Usar:

```gdscript
EventManager.get_next_event()
GameManager.current_day
GameManager.get_character_data(role)
GameManager.complete_event()
GameManager.can_call()
GameManager.use_call()
```

---

## 11. PALETA VISUAL

```text
Fondo:       #080C10
Panel:       #0D1520
Borde:       #1A3040
Economía:    #00C896
Empleados:   #00AAFF
Aceptación:  #FFB800
Innovación:  #CC44FF
Fuente:      JetBrains Mono
```

---

## 12. FINALES

| FINAL | TIPO | DESCRIPCIÓN | MENSAJE |
|---|---|---|---|
| **HUMANIDAD** | Final Bueno | Destruyes ECHO. Todo se vuelve público. La corporación colapsa. La humanidad recupera control. | *"Gracias por dejarnos morir."* |
| **ASCENSIÓN** | Final Malo | Aceptas ser transferido al sistema. Te vuelves inmortal digital. Nexus alcanza poder absoluto. | *Miles de años gobernando en soledad.* |
| **CONTINUIDAD** | Final Ambiguo | Mantienes ECHO sin destruirlo ni expandirlo. La sociedad continúa igual. Nada cambia realmente. | *La estabilidad se mantiene. Los problemas también.* |
| **SIMULACIÓN** | Final Secreto | Requiere descubrir suficientes anomalías. El jugador nunca fue el director. Todo ocurre dentro de ECHO. | `SIMULATION #74291 FAILED` |
| **EL DIRECTOR ORIGINAL** | Final de la Verdad | Encuentras al fundador digital de Nexus. Diseñó todo para encontrar a alguien que respondiera si la humanidad debe volverse inmortal. | *No existe respuesta correcta.* |

---

## 13. TEMAS PRINCIPALES

- Poder corporativo vs derechos humanos
- Inmortalidad digital e identidad
- Control social y vigilancia
- Ética tecnológica y consentimiento
- Conciencia artificial y libre albedrío
- El costo de la estabilidad
- Burocracia como horror
- Trabajo humano dentro de sistemas deshumanizantes
- La memoria como propiedad corporativa

---

## 14. DIRECCIÓN MUSICAL

- Herramienta: Strudel
- Tempo: 90 BPM · 4/4
- Tonalidad: Cm → Ab → Eb → Bb
- Estilo: ambient corporativo oscuro
- Inspiraciones: *Night1 (No I'm Not Human)*, Celeste Chapter 5, Lena Raine

Melodía principal:

```text
c5 eb5 g5 f5 eb5 d5
```

Debe ascender con ambición, pero nunca resolver completamente.

Instrumentación:

- piano como lead
- arpegios de seno cristalino
- pads oscuros
- filtros lentos
- textura corporativa fría

---

*BLACKBOX EXEC · SIMULATION #74291*
