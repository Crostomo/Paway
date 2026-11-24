
extends RefCounted

const TipoRegistroEstadisticas = preload(
    "res://scripts/datos/modelos/registro_estadisticas.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_registro_estadisticas.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorRegistroEstadisticas ---")

	var estadisticas = TipoRegistroEstadisticas.new()

	estadisticas.version_formato = 1
	estadisticas.partidas_completadas = 12
	estadisticas.intentos_no_completados = 3
	estadisticas.movimientos_realizados = 250
	estadisticas.movimientos_deshechados = 40
	estadisticas.movimientos_efectivos = 210
	estadisticas.tiempo_total_segundos = 1850.5
	estadisticas.mayor_tablero_no_completado = 24
	estadisticas.pistas_utilizadas = 7

	estadisticas.mejores_tiempos["5x5"] = 125.5
	estadisticas.mejores_tiempos["5x6"] = 180.0

	estadisticas.historial_partidas.append({
		"id_partida": "partida_001",
		"filas": 5,
		"columnas": 5,
		"tiempo_segundos": 125.5,
		"completada": true
	})

	estadisticas.historial_partidas.append({
		"id_partida": "partida_002",
		"filas": 5,
		"columnas": 6,
		"tiempo_segundos": 180.0,
		"completada": true
	})

	estadisticas.ultima_actualizacion = "2026-11-23T12:00:00"

	var resultado_serializacion = TipoSerializador.serializar(
		estadisticas
	)

	if resultado_serializacion == null:
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error: ", resultado_serializacion.datos)
		push_error("Fallo al serializar las estadisticas.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		resultado_serializacion.datos["datos"]
	)

	if resultado_deserializacion == null:
		push_error("La deserializacion ha devuelto null.")
		return false

	if not resultado_deserializacion.aceptado:
		print("Error: ", resultado_deserializacion.datos)
		push_error("Fallo al deserializar las estadisticas.")
		return false

	var reconstruidas = resultado_deserializacion.datos["estadisticas"]

	if reconstruidas.partidas_completadas != estadisticas.partidas_completadas:
		push_error("Las partidas completadas no coinciden.")
		return false

	if reconstruidas.intentos_no_completados != estadisticas.intentos_no_completados:
		push_error("Los intentos no completados no coinciden.")
		return false

	if reconstruidas.movimientos_realizados != estadisticas.movimientos_realizados:
		push_error("Los movimientos realizados no coinciden.")
		return false

	if reconstruidas.movimientos_deshechados != estadisticas.movimientos_deshechados:
		push_error("Los movimientos deshechos no coinciden.")
		return false

	if reconstruidas.movimientos_efectivos != estadisticas.movimientos_efectivos:
		push_error("Los movimientos efectivos no coinciden.")
		return false

	if reconstruidas.tiempo_total_segundos != estadisticas.tiempo_total_segundos:
		push_error("El tiempo total no coincide.")
		return false

	if reconstruidas.mayor_tablero_no_completado != estadisticas.mayor_tablero_no_completado:
		push_error("El mayor tablero no completado no coincide.")
		return false

	if reconstruidas.pistas_utilizadas != estadisticas.pistas_utilizadas:
		push_error("Las pistas utilizadas no coinciden.")
		return false

	if reconstruidas.mejores_tiempos != estadisticas.mejores_tiempos:
		push_error("Los mejores tiempos no coinciden.")
		return false

	if reconstruidas.historial_partidas != estadisticas.historial_partidas:
		push_error("El historial de partidas no coincide.")
		return false

	if reconstruidas.ultima_actualizacion != estadisticas.ultima_actualizacion:
		push_error("La fecha de actualizacion no coincide.")
		return false

	print("RESULTADO: CORRECTO")
	return true
