
class_name SerializadorRegistroEstadisticas
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoRegistroEstadisticas = preload(
    "res://scripts/datos/modelos/registro_estadisticas.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func serializar(
	estadisticas: TipoRegistroEstadisticas
) -> TipoResultadoOperacion:

	if estadisticas == null:
		return _error("ESTADISTICAS_NO_VALIDAS")

	if estadisticas.version_formato != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	if not _validar_valores(estadisticas):
		return _error("VALORES_ESTADISTICAS_NO_VALIDOS")

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"partidas_completadas": estadisticas.partidas_completadas,
		"intentos_no_completados": estadisticas.intentos_no_completados,
		"movimientos_realizados": estadisticas.movimientos_realizados,
		"movimientos_deshechos": estadisticas.movimientos_deshechos,
		"movimientos_efectivos": estadisticas.movimientos_efectivos,
		"tiempo_total_segundos": estadisticas.tiempo_total_segundos,
		"mayor_tablero_no_completado": estadisticas.mayor_tablero_no_completado,
		"pistas_utilizadas": estadisticas.pistas_utilizadas,
		"mejores_tiempos": estadisticas.mejores_tiempos.duplicate(true),
		"historial_partidas": estadisticas.historial_partidas.duplicate(true),
		"ultima_actualizacion": estadisticas.ultima_actualizacion
	}

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"datos": datos}
	)


static func deserializar(datos: Dictionary) -> TipoResultadoOperacion:

	if not datos.has("version_formato"):
		return _error("FALTA_VERSION_FORMATO")

	if not (datos["version_formato"] is int):
		return _error("VERSION_FORMATO_NO_VALIDA")

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var campos_enteros: Array[String] = [
		"partidas_completadas",
		"intentos_no_completados",
		"movimientos_realizados",
		"movimientos_deshechos",
		"movimientos_efectivos",
		"mayor_tablero_no_completado",
        "pistas_utilizadas"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO", {"campo": campo})

		if datos[campo] < 0:
			return _error("VALOR_NEGATIVO", {"campo": campo})

	if not datos.has("tiempo_total_segundos"):
		return _error("FALTA_TIEMPO_TOTAL")

	if not _es_numero(datos["tiempo_total_segundos"]):
		return _error("TIEMPO_TOTAL_NO_VALIDO")

	if datos["tiempo_total_segundos"] < 0:
		return _error("TIEMPO_TOTAL_NEGATIVO")

	if not datos.has("mejores_tiempos") or not (datos["mejores_tiempos"] is Dictionary):
		return _error("MEJORES_TIEMPOS_NO_VALIDOS")

	if not datos.has("historial_partidas") or not (datos["historial_partidas"] is Array):
		return _error("HISTORIAL_NO_VALIDO")

	if not datos.has("ultima_actualizacion") or not (datos["ultima_actualizacion"] is String):
		return _error("FECHA_NO_VALIDA")

	var estadisticas := TipoRegistroEstadisticas.new()

	estadisticas.version_formato = VERSION_FORMATO
	estadisticas.partidas_completadas = datos["partidas_completadas"]
	estadisticas.intentos_no_completados = datos["intentos_no_completados"]
	estadisticas.movimientos_realizados = datos["movimientos_realizados"]
	estadisticas.movimientos_deshechos = datos["movimientos_deshechos"]
	estadisticas.movimientos_efectivos = datos["movimientos_efectivos"]
	estadisticas.tiempo_total_segundos = float(datos["tiempo_total_segundos"])
	estadisticas.mayor_tablero_no_completado = datos["mayor_tablero_no_completado"]
	estadisticas.pistas_utilizadas = datos["pistas_utilizadas"]
	estadisticas.mejores_tiempos = datos["mejores_tiempos"].duplicate(true)
	estadisticas.ultima_actualizacion = datos["ultima_actualizacion"]

	for registro in datos["historial_partidas"]:
		if not (registro is Dictionary):
			return _error("REGISTRO_HISTORIAL_NO_VALIDO")

		estadisticas.historial_partidas.append(registro.duplicate(true))

	if not _validar_valores(estadisticas):
		return _error("VALORES_ESTADISTICAS_NO_VALIDOS")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"estadisticas": estadisticas}
	)


static func _validar_valores(
	estadisticas: TipoRegistroEstadisticas
) -> bool:

	if estadisticas.partidas_completadas < 0:
		return false

	if estadisticas.intentos_no_completados < 0:
		return false

	if estadisticas.movimientos_realizados < 0:
		return false

	if estadisticas.movimientos_deshechos < 0:
		return false

	if estadisticas.movimientos_efectivos < 0:
		return false

	if estadisticas.movimientos_efectivos != (
		estadisticas.movimientos_realizados
		- estadisticas.movimientos_deshechos
	):
		return false

	if estadisticas.tiempo_total_segundos < 0:
		return false

	if estadisticas.mayor_tablero_no_completado < 0:
		return false

	if estadisticas.pistas_utilizadas < 0:
		return false

	return true


static func _es_numero(valor: Variant) -> bool:
	return valor is int or valor is float


static func _error(
	motivo: String,
	detalles: Dictionary = {}
) -> TipoResultadoOperacion:

	var datos_error: Dictionary = {"motivo": motivo}
	datos_error.merge(detalles)

	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		datos_error
	)
