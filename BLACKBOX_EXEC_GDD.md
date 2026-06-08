# BLACKBOX EXEC
### Game Design Document
`Godot 3 · GDScript · Reigns-style`

---

> *Año 2089. Las megacorporaciones reemplazaron a los gobiernos.*
> *Tú eres el Director Ejecutivo de Nexus Industries. Tu objetivo parece simple.*

---

## 01. PREMISA

El jugador asume el rol de Director Ejecutivo de Nexus Industries, corporación tecnológica especializada en inteligencia artificial, implantes neuronales y sistemas de automatización.

El objetivo aparente es mantener la corporación funcionando. A medida que avanzan los turnos, anomalías crecientes revelan que la empresa oculta algo mucho más grande.

*Jugabilidad inspirada en Reigns: decisiones binarias con consecuencias en cuatro estadísticas.*

---

## 02. ESTADÍSTICAS

Cualquier stat en 0 termina la partida.

| STAT | DESCRIPCIÓN | SI LLEGA A 0 |
|---|---|---|
| **Economía** | Recursos financieros corporativos | Bancarrota → Fin de partida |
| **Aceptación** | Opinión pública y reputación | Protestas masivas → Intervención gubernamental |
| **Empleados** | Moral, productividad y lealtad | Huelgas, sabotajes, colapso operativo |
| **Innovación** | Capacidad tecnológica y científica | Corporación obsoleta → Competencia domina |

---

## 03. ESTRUCTURA NARRATIVA

### FASE 1 — LA CORPORACIÓN `[Turnos 1–30]`

La partida parece un simulador corporativo tradicional. Eventos giran alrededor de contrataciones, marketing, presupuestos, desarrollo tecnológico, satisfacción de empleados y relaciones con clientes.

Durante esta fase aparecen pequeñas anomalías que parecen errores administrativos o técnicos:

- Tarjetas de acceso desconocidas
- Servidores activos sin explicación
- Registros incompletos
- Departamentos poco documentados

El jugador no tiene pruebas de que exista una conspiración.

```
EVENTO FINAL FASE 1:
Se pierde acceso a un laboratorio interno.
Nadie sabe quién modificó las credenciales.
```

---

### FASE 2 — LA CONSPIRACIÓN `[Turnos 31–75]`

Las anomalías comienzan a conectarse. Aparecen filtraciones, archivos clasificados, registros eliminados y mensajes anónimos.

El jugador descubre referencias al **Proyecto ECHO** — oficialmente cancelado hace años, pero que sigue recibiendo presupuesto, utilizando servidores y generando actividad.

Mensajes del Director Anterior comienzan a aparecer:

```
"NO CONFÍES EN LOS ARCHIVOS OFICIALES"
"YO FUI DIRECTOR ANTES QUE TÚ"
"NO DEJES QUE TE COPIEN"
```

```
EVENTO FINAL FASE 2:
El jugador descubre parcialmente la verdad.
Proyecto ECHO es tecnología capaz de copiar y almacenar conciencias humanas.
```

---

### FASE 3 — LA VERDAD `[Turnos 76–110]`

Todas las decisiones tomadas durante la partida comienzan a tener consecuencias. El jugador descubre:

- ECHO nunca fue cancelado
- Existen miles de conciencias almacenadas
- Directivos históricos continúan existiendo digitalmente
- El anterior director sigue activo dentro del sistema
- La Junta Directiva está parcialmente compuesta por copias digitales

La Científica revela información crítica. La IA Malvada comienza a comunicarse directamente con el jugador. El jugador debe decidir el futuro de ECHO.

---

## 04. PROYECTO ECHO

Proyecto secreto de Nexus Industries. Objetivo original: preservar la conciencia humana mediante transferencia digital.

Con el paso del tiempo evolucionó hasta convertirse en una red masiva de almacenamiento de mentes. Miles de personas han sido copiadas. Algunas continúan funcionando dentro de los sistemas corporativos.

*La verdadera naturaleza de ECHO depende de las decisiones acumuladas del jugador a lo largo de las tres fases.*

---
## 05. PERSONAJES

### Elenco Principal

| PERSONAJE                            | ROL / NOTAS                                                                                                                                                       |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cherry**                           | Tutorial y guía inicial. Punto de entrada para el jugador.                                                                                                        |
| **Claire / RRHH**                    | Contrataciones, despidos, bienestar laboral. Genera reportes con consecuencias narrativas.                                                                        |
| **Ellis / Contador**                 | Economía, presupuestos, inversiones. Fuente de presión fiscal constante.                                                                                          |
| **Harmon / Cliente**                 | Contratos y oportunidades de negocio. Presión sobre Economía vs Aceptación.                                                                                       |
| **Vera Knox / Community Manager**    | Imagen pública y reputación. Gestiona crisis de Aceptación, campañas y escándalos mediáticos.                                                                     |
| **#2847 / Trabajador**               | Perspectiva interna de empleados. Voz de la base laboral. Su anonimato refuerza la deshumanización corporativa.                                                   |
| **Kevin / Programador**              | Sistemas informáticos y desarrollo. Introduce bugs con consecuencias narrativas.                                                                                  |
| **Iris Vale / Diseñadora**           | Diseño de productos e identidad corporativa. Impacta Aceptación e Innovación.                                                                                     |
| **Dra. Helena Voss / Científica**    | Investigación avanzada. Figura central en la revelación del Proyecto ECHO.                                                                                        |
| **Bruno Kade / Mantenimiento**       | Infraestructura y anomalías técnicas. Primeras señales de algo oculto.                                                                                            |
| **Don Rubén / Conserje**             | Observaciones extrañas. Conoce secretos internos sin entender su alcance.                                                                                         |
| **Sandra Veil / Periodista**         | Investigaciones externas y filtraciones. Evento fijo en turno 10.                                                                                                 |
| **Mara Sol / Activista**             | Presión social y movimientos ciudadanos. Afecta Aceptación y Empleados.                                                                                           |
| **Null / Hacker**                    | Intrusiones, filtraciones y eventos ocultos. Puede revelar datos clasificados.                                                                                    |
| **Reeves / Agente Federal**          | Investigaciones oficiales. Flag `reeves_flagged` desencadena consecuencias en Act 2.                                                                              |
| **CORE / IA Malvada**                | Antagonista principal. Seed en Act 1, comunicación directa en Act 3.                                                                                              |
| **Silas Veyr / Antiguo Director**    | Personaje oculto. Se comunica mediante mensajes anónimos en Fase 2. Conciencia digital almacenada en ECHO. Figura narrativa central de Fases 2 y 3.               |
| **Victor Harlowe / Inversionista**   | Representa accionistas poderosos. Exige despidos, recortes, automatización y expansión agresiva. Tensión constante entre Economía y bienestar humano.             |
| **Eleanor Strake / Junta Directiva** | Representante ejecutiva de la Junta. Parece normal en Fase 1. En Fase 3 se revela que conoce la naturaleza real de ECHO y puede ser una copia digital.            |
| **Dra. Naomi Kess / Médica**         | Salud laboral, implantes neuronales y ética biomédica. Clave cuando ECHO interactúa con cerebros humanos. Puede ser aliada o rival de Voss.                       |
| **Darius Flint / Seguridad**         | Vigilancia corporativa y protección de activos. Propone monitoreo, reconocimiento facial y control interno. Beneficia Economía, perjudica Aceptación y Empleados. |
| **Tiempo**                           | Sistema narrativo/meta. Representa plazos, deterioro, cuenta regresiva y eventos inevitables. No necesita nombre propio.                                          |

---

### Criterio de nombres

Los personajes con peso narrativo, conflicto directo o participación recurrente tienen nombre propio. Los personajes simbólicos o sistémicos conservan una identidad funcional.

| TIPO               | EJEMPLOS                                                        |
| ------------------ | --------------------------------------------------------------- |
| **Nombre propio**  | Claire, Ellis, Kevin, Sandra Veil, Dra. Helena Voss, Silas Veyr |
| **Alias / código** | Null, #2847, CORE                                               |
| **Rol simbólico**  | Tiempo                                                          |

---


## 06. FINALES

| FINAL | TIPO | DESCRIPCIÓN | MENSAJE |
|---|---|---|---|
| **HUMANIDAD** | Final Bueno | Destruyes ECHO. Todo se vuelve público. La corporación colapsa. La humanidad recupera control. | *"Gracias por dejarnos morir."* |
| **ASCENSIÓN** | Final Malo | Aceptas ser transferido al sistema. Te vuelves inmortal digital. Nexus alcanza poder absoluto. | *Miles de años gobernando en soledad.* |
| **CONTINUIDAD** | Final Ambiguo | Mantienes ECHO sin destruirlo ni expandirlo. La sociedad continúa exactamente igual. Nada cambia. | *La estabilidad se mantiene. Los problemas también.* |
| **SIMULACIÓN** | Final Secreto | Requiere descubrir suficientes anomalías. El jugador nunca fue el director. Todo ocurre dentro de ECHO. | `SIMULATION #74291 FAILED` |
| **EL DIRECTOR ORIGINAL** | Final de la Verdad | Encuentras al fundador digital de Nexus. Diseñó todo para encontrar a alguien que respondiera: ¿Debe la humanidad volverse inmortal? La partida termina antes de que decidas. | *No existe respuesta correcta.* |

---

## 07. TEMAS PRINCIPALES

- Poder corporativo vs derechos humanos
- Inmortalidad digital e identidad
- Control social y vigilancia
- Ética tecnológica y consentimiento
- Conciencia artificial y libre albedrío
- El costo de la estabilidad
- La naturaleza de la humanidad

---

## 08. IMPLEMENTACIÓN TÉCNICA

### Stack

- Motor: Godot 3.x
- Lenguaje: GDScript
- Resolución: 1024×512
- Layout: dos columnas (izquierda: diálogo/botones · derecha: stats)

### Arquitectura

- `GameManager.gd` — autoload singleton, stats, signals, flags
- `EventManager.gd` — pool de eventos, fixed-position events, `used_events`, `flags_messages`
- `DilemmaUI.gd` — UI reactiva, typewriter animation, hover effects

### Paleta Visual

```
Fondo:       #080C10
Panel:       #0D1520
Borde:       #1A3040
Economía:    #00C896  (Botón B)
Empleados:   #00AAFF  (Botón A)
Aceptación:  #FFB800
Innovación:  #CC44FF
Fuente:      JetBrains Mono
```

### Flags Críticos

```gdscript
reeves_flagged          # consecuencias en Act 2
core_anomaly_accepted   # seed para Act 3 villain
core_anomaly_rejected   # bloquea ciertas rutas de ECHO
```

### Eventos Fijos

| Turno | Evento |
|---|---|
| 10 | Sandra Veil — primer contacto externo |
| 15 | CORE anomalous suggestion — seed del antagonista |

---

## 09. DIRECCIÓN MUSICAL

- Herramienta: Strudel
- Tempo: 90 BPM · 4/4
- Tonalidad: Cm → Ab → Eb → Bb
- Estilo: ambient corporativo oscuro
- Inspiraciones: *Night1 (No I'm Not Human)*, Celeste Chapter 5, Lena Raine

Melodía principal: `c5 eb5 g5 f5 eb5 d5` — asciende con ambición, nunca resuelve.

- Piano como lead
- Arpegios de seno cristalino
- Pad de diente de sierra con LFO en LPF

---

*BLACKBOX EXEC · SIMULATION #74291*
