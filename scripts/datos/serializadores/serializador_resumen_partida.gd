
class_name SerializadorResumenPartida
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoResumenPartida = preload(
    "res://scripts/datos/modelos/resumen_partida.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func serializar(
	resumen: TipoResumenPartida
) -> TipoResultadoOperacion:

	if not _validar(resumen):
		return _error("RESUMEN_PARTIDA_NO_VALIDO")

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"id_partida": resumen.id_partida,
		"tipo_partida": resumen.tipo_partida,
		"estado": resumen.estado,
		"tiempo_segundos": resumen.tiempo_segundos,
		"usar_cronometro": resumen.usar_cronometro,
		"pistas_utilizadas": resumen.pistas_utilizadas,
		"resultado_registrado": resumen.resultado_registrado,
		"id_reto": resumen.id_reto
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

	var campos_texto: Array[String] = [
		"id_partida",
		"tipo_partida",
		"estado",
        "id_reto"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

	var campos_booleanos: Array[String] = [
		"usar_cronometro",
        "resultado_registrado"
	]

	for campo in campos_booleanos:
		if not datos.has(campo) or not (datos[campo] is bool):
			return _error("CAMPO_BOOLEANO_NO_VALIDO", {"campo": campo})

	if not datos.has("tiempo_segundos"):
		return _error("FALTA_TIEMPO")

	if not _es_numero(datos["tiempo_segundos"]):
		return _error("TIEMPO_NO_VALIDO")

	if not datos.has("pistas_utilizadas"):
		return _error("FALTA_CONTADOR_PISTAS")

	if not (datos["pistas_utilizadas"] is int):
		return _error("CONTADOR_PISTAS_NO_VALIDO")

	var resumen := TipoResumenPartida.new()

	resumen.id_partida = datos["id_partida"]
	resumen.tipo_partida = datos["tipo_partida"]
	resumen.estado = datos["estado"]
	resumen.tiempo_segundos = float(datos["tiempo_segundos"])
	resumen.usar_cronometro = datos["usar_cronometro"]
	resumen.pistas_utilizadas = datos["pistas_utilizadas"]
	resumen.resultado_registrado = datos["resultado_registrado"]
	resumen.id_reto = datos["id_reto"]

	if not _validar(resumen):
		return _error("RESUMEN_PARTIDA_NO_VALIDO")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"resumen": resumen}
	)


static func _validar(
	resumen: TipoResumenPartida
) -> bool:

	if resumen == null:
		return false

	if resumen.id_partida.strip_edges().is_empty():
		return false

	var tipos_validos: Array[String] = [
		"normal",
		"personalizada",
        "reto"
	]

	if resumen.tipo_partida not in tipos_validos:
		return false

	if resumen.tipo_partida == "reto" and resumen.id_reto.strip_edges().is_empty():
		return false

	var estados_validos: Array[String] = [
		TipoResumenPartida.ESTADO_PREPARADA,
		TipoResumenPartida.ESTADO_ACTIVA,
		TipoResumenPartida.ESTADO_PAUSADA,
		TipoResumenPartida.ESTADO_BLOQUEADA,
		TipoResumenPartida.ESTADO_COMPLETADA,
		TipoResumenPartida.ESTADO_ABANDONADA
	]

	if resumen.estado not in estados_validos:
		return false

	if resumen.tiempo_segundos < 0:
		return false

	if resumen.pistas_utilizadas < 0:
		return false

	if resumen.resultado_registrado:
		if resumen.estado != TipoResumenPartida.ESTADO_COMPLETADA:
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
