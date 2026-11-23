
class_name SerializadorResultadoAnalisis
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoResultadoAnalisis = preload(
    "res://scripts/datos/modelos/resultado_analisis.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func serializar(
	analisis: TipoResultadoAnalisis
) -> TipoResultadoOperacion:

	if not _validar(analisis):
		return _error("RESULTADO_ANALISIS_NO_VALIDO")

	var recorrido: Array[Dictionary] = []

	for posicion in analisis.recorrido_referencia:
		recorrido.append({
			"x": posicion.x,
			"y": posicion.y
		})

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"id_tablero": analisis.id_tablero,
		"id_problema": analisis.id_problema,
		"certificacion": analisis.certificacion,
		"tipo_recuento": analisis.tipo_recuento,
		"soluciones_minimas": analisis.soluciones_minimas,
		"soluciones_maximas": analisis.soluciones_maximas,
		"recuento_exacto": analisis.recuento_exacto,
		"recorrido_referencia": recorrido,
		"analisis_completo": analisis.analisis_completo,
		"tiempo_segundos": analisis.tiempo_segundos,
		"nodos_explorados": analisis.nodos_explorados,
		"version_algoritmo": analisis.version_algoritmo,
		"validacion_independiente_superada": analisis.validacion_independiente_superada
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
		"id_tablero",
		"id_problema",
		"certificacion",
		"tipo_recuento",
        "version_algoritmo"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

	var campos_enteros: Array[String] = [
		"soluciones_minimas",
		"soluciones_maximas",
		"recuento_exacto",
        "nodos_explorados"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO", {"campo": campo})

	var campos_booleanos: Array[String] = [
		"analisis_completo",
        "validacion_independiente_superada"
	]

	for campo in campos_booleanos:
		if not datos.has(campo) or not (datos[campo] is bool):
			return _error("CAMPO_BOOLEANO_NO_VALIDO", {"campo": campo})

	if not datos.has("tiempo_segundos"):
		return _error("FALTA_TIEMPO")

	if not _es_numero(datos["tiempo_segundos"]):
		return _error("TIEMPO_NO_VALIDO")

	if not datos.has("recorrido_referencia"):
		return _error("FALTA_RECORRIDO")

	if not (datos["recorrido_referencia"] is Array):
		return _error("RECORRIDO_NO_VALIDO")

	var analisis := TipoResultadoAnalisis.new()

	analisis.id_tablero = datos["id_tablero"]
	analisis.id_problema = datos["id_problema"]
	analisis.certificacion = datos["certificacion"]
	analisis.tipo_recuento = datos["tipo_recuento"]
	analisis.soluciones_minimas = datos["soluciones_minimas"]
	analisis.soluciones_maximas = datos["soluciones_maximas"]
	analisis.recuento_exacto = datos["recuento_exacto"]
	analisis.analisis_completo = datos["analisis_completo"]
	analisis.tiempo_segundos = float(datos["tiempo_segundos"])
	analisis.nodos_explorados = datos["nodos_explorados"]
	analisis.version_algoritmo = datos["version_algoritmo"]
	analisis.validacion_independiente_superada = datos[
        "validacion_independiente_superada"
	]

	for posicion in datos["recorrido_referencia"]:
		if not (posicion is Dictionary):
			return _error("POSICION_NO_VALIDA")

		if not posicion.has("x") or not (posicion["x"] is int):
			return _error("COORDENADA_X_NO_VALIDA")

		if not posicion.has("y") or not (posicion["y"] is int):
			return _error("COORDENADA_Y_NO_VALIDA")

		analisis.recorrido_referencia.append(
			Vector2i(posicion["x"], posicion["y"])
		)

	if not _validar(analisis):
		return _error("RESULTADO_ANALISIS_NO_VALIDO")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"analisis": analisis}
	)


static func _validar(
	analisis: TipoResultadoAnalisis
) -> bool:

	if analisis == null:
		return false

	if analisis.id_tablero.is_empty():
		return false

	if analisis.id_problema.is_empty():
		return false

	var certificaciones: Array[String] = [
		TipoResultadoAnalisis.CERTIFICACION_PENDIENTE,
		TipoResultadoAnalisis.CERTIFICACION_SOLVENCIA,
		TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA,
		TipoResultadoAnalisis.CERTIFICACION_IMPOSIBILIDAD,
		TipoResultadoAnalisis.CERTIFICACION_INCOMPLETA
	]

	if analisis.certificacion not in certificaciones:
		return false

	var tipos_recuento: Array[String] = [
		TipoResultadoAnalisis.RECUENTO_NO_DETERMINADO,
		TipoResultadoAnalisis.RECUENTO_EXACTO,
		TipoResultadoAnalisis.RECUENTO_BANDA,
		TipoResultadoAnalisis.RECUENTO_LIMITE_INFERIOR
	]

	if analisis.tipo_recuento not in tipos_recuento:
		return false

	if analisis.soluciones_minimas < 0:
		return false

	if analisis.soluciones_maximas < 0:
		return false

	if analisis.recuento_exacto < -1:
		return false

	if analisis.tiempo_segundos < 0:
		return false

	if analisis.nodos_explorados < 0:
		return false

	if analisis.tipo_recuento == TipoResultadoAnalisis.RECUENTO_EXACTO:
		if analisis.recuento_exacto < 0:
			return false

		if analisis.soluciones_minimas != analisis.recuento_exacto:
			return false

		if analisis.soluciones_maximas != analisis.recuento_exacto:
			return false

	elif analisis.recuento_exacto != -1:
		return false

	if analisis.soluciones_maximas > 0:
		if analisis.soluciones_minimas > analisis.soluciones_maximas:
			return false

	if analisis.certificacion == TipoResultadoAnalisis.CERTIFICACION_IMPOSIBILIDAD:
		if not analisis.analisis_completo:
			return false

		if not analisis.recorrido_referencia.is_empty():
			return false

	if analisis.certificacion == TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA:
		if not analisis.analisis_completo:
			return false

	if analisis.validacion_independiente_superada:
		if analisis.recorrido_referencia.is_empty():
			return false

	for posicion in analisis.recorrido_referencia:
		if posicion.x < 0 or posicion.y < 0:
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
