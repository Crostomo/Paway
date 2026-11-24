
extends RefCounted

const TipoDatosProgreso = preload(
    "res://scripts/datos/modelos/datos_progreso.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_datos_progreso.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorDatosProgreso ---")

	var progreso = TipoDatosProgreso.new()

	progreso.version_formato = 1
	progreso.experiencia_total = 1250
	progreso.nivel_actual = 4
	progreso.recompensas_concedidas.append("primera_partida")
	progreso.recompensas_concedidas.append("primer_tablero_5x5")
	progreso.recompensas_concedidas.append("primer_reto")

	progreso.dimensiones_completadas.append("5x5")
	progreso.dimensiones_completadas.append("5x6")
	progreso.dimensiones_completadas.append("6x6")
	progreso.ultima_actualizacion = "2026-11-23T12:00:00"

	var resultado_serializacion = TipoSerializador.serializar(progreso)

	if resultado_serializacion == null or not resultado_serializacion.aceptado:
		push_error("Fallo al serializar los datos de progreso.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		resultado_serializacion.datos["datos"]
	)

	if resultado_deserializacion == null or not resultado_deserializacion.aceptado:
		push_error("Fallo al deserializar los datos de progreso.")
		return false

	var reconstruido = resultado_deserializacion.datos["progreso"]

	if reconstruido.version_formato != progreso.version_formato:
		push_error("La version del formato no coincide.")
		return false

	if reconstruido.experiencia_total != progreso.experiencia_total:
		push_error("La experiencia total no coincide.")
		return false

	if reconstruido.nivel_actual != progreso.nivel_actual:
		push_error("El nivel actual no coincide.")
		return false

	if reconstruido.recompensas_concedidas != progreso.recompensas_concedidas:
		push_error("Las recompensas concedidas no coinciden.")
		return false

	if reconstruido.dimensiones_completadas != progreso.dimensiones_completadas:
		push_error("Las dimensiones completadas no coinciden.")
		return false

	if reconstruido.ultima_actualizacion != progreso.ultima_actualizacion:
		push_error("La fecha de actualizacion no coincide.")
		return false

	print("RESULTADO: CORRECTO")
	return true
