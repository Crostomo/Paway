
class_name SerializadorDatosCatalogo
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoDatosCatalogo = preload(
    "res://scripts/datos/modelos/datos_catalogo.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoResultadoAnalisis = preload(
    "res://scripts/datos/modelos/resultado_analisis.gd"
)


static func serializar(
	catalogo: TipoDatosCatalogo
) -> TipoResultadoOperacion:

	if not _validar(catalogo):
		return _error("DATOS_CATALOGO_NO_VALIDOS")

	var recorridos: Array[Array] = []

	for recorrido in catalogo.recorridos_referencia:
		var recorrido_serializado: Array[Dictionary] = []

		for posicion in recorrido:
			if not (posicion is Vector2i):
				return _error("POSICION_RECORRIDO_NO_VALIDA")

			recorrido_serializado.append({
				"x": posicion.x,
				"y": posicion.y
			})

		recorridos.append(recorrido_serializado)

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"version_reglas": catalogo.version_reglas,
		"id_tablero": catalogo.id_tablero,
		"filas": catalogo.filas,
		"columnas": catalogo.columnas,
		"certificacion": catalogo.certificacion,
		"cobertura_completa": catalogo.cobertura_completa,
		"inicios_comprobados": catalogo.inicios_comprobados,
		"total_inicios": catalogo.total_inicios,
		"tipo_recuento": catalogo.tipo_recuento,
		"soluciones_minimas": catalogo.soluciones_minimas,
		"soluciones_maximas": catalogo.soluciones_maximas,
		"recuento_exacto": catalogo.recuento_exacto,
		"recorridos_referencia": recorridos,
		"tiempo_analisis_segundos": catalogo.tiempo_analisis_segundos,
		"nodos_explorados": catalogo.nodos_explorados,
		"version_algoritmo": catalogo.version_algoritmo,
		"validacion_independiente_superada": catalogo.validacion_independiente_superada,
		"identificador_integridad": catalogo.identificador_integridad
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
		"certificacion",
		"tipo_recuento",
		"version_algoritmo",
        "identificador_integridad"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

	var campos_enteros: Array[String] = [
		"version_reglas",
		"filas",
		"columnas",
		"inicios_comprobados",
		"total_inicios",
		"soluciones_minimas",
		"soluciones_maximas",
		"recuento_exacto",
        "nodos_explorados"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO", {"campo": campo})

	var campos_booleanos: Array[String] = [
		"cobertura_completa",
        "validacion_independiente_superada"
	]

	for campo in campos_booleanos:
		if not datos.has(campo) or not (datos[campo] is bool):
			return _error("CAMPO_BOOLEANO_NO_VALIDO", {"campo": campo})

	if not datos.has("tiempo_analisis_segundos"):
		return _error("FALTA_TIEMPO_ANALISIS")

	if not _es_numero(datos["tiempo_analisis_segundos"]):
		return _error("TIEMPO_ANALISIS_NO_VALIDO")

	if not datos.has("recorridos_referencia"):
		return _error("FALTA_RECORRIDOS")

	if not (datos["recorridos_referencia"] is Array):
		return _error("RECORRIDOS_NO_VALIDOS")

	var catalogo := TipoDatosCatalogo.new()

	catalogo.version_reglas = datos["version_reglas"]
	catalogo.id_tablero = datos["id_tablero"]
	catalogo.filas = datos["filas"]
	catalogo.columnas = datos["columnas"]
	catalogo.certificacion = datos["certificacion"]
	catalogo.cobertura_completa = datos["cobertura_completa"]
	catalogo.inicios_comprobados = datos["inicios_comprobados"]
	catalogo.total_inicios = datos["total_inicios"]
	catalogo.tipo_recuento = datos["tipo_recuento"]
	catalogo.soluciones_minimas = datos["soluciones_minimas"]
	catalogo.soluciones_maximas = datos["soluciones_maximas"]
	catalogo.recuento_exacto = datos["recuento_exacto"]
	catalogo.tiempo_analisis_segundos = float(
		datos["tiempo_analisis_segundos"]
	)
	catalogo.nodos_explorados = datos["nodos_explorados"]
	catalogo.version_algoritmo = datos["version_algoritmo"]
	catalogo.validacion_independiente_superada = (
		datos["validacion_independiente_superada"]
	)
	catalogo.identificador_integridad = datos["identificador_integridad"]

	for recorrido in datos["recorridos_referencia"]:
		if not (recorrido is Array):
			return _error("RECORRIDO_NO_VALIDO")

		var recorrido_reconstruido: Array[Vector2i] = []

		for posicion in recorrido:
			if not (posicion is Dictionary):
				return _error("POSICION_NO_VALIDA")

			if not posicion.has("x") or not (posicion["x"] is int):
				return _error("COORDENADA_X_NO_VALIDA")

			if not posicion.has("y") or not (posicion["y"] is int):
				return _error("COORDENADA_Y_NO_VALIDA")

			recorrido_reconstruido.append(
				Vector2i(posicion["x"], posicion["y"])
			)

		catalogo.recorridos_referencia.append(recorrido_reconstruido)

	if not _validar(catalogo):
		return _error("DATOS_CATALOGO_NO_VALIDOS")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"catalogo": catalogo}
	)


static func _validar(catalogo: TipoDatosCatalogo) -> bool:

	if catalogo == null:
		return false

	if catalogo.version_reglas < 1:
		return false

	if catalogo.id_tablero.strip_edges().is_empty():
		return false

	if catalogo.filas < 5 or catalogo.columnas < 5:
		return false

	if catalogo.filas * catalogo.columnas > 500:
		return false

	if catalogo.inicios_comprobados < 0:
		return false

	if catalogo.total_inicios < 0:
		return false

	if catalogo.inicios_comprobados > catalogo.total_inicios:
		return false

	if catalogo.cobertura_completa:
		if catalogo.total_inicios <= 0:
			return false
			
		if catalogo.inicios_comprobados != catalogo.total_inicios:
			return false

		if catalogo.certificacion != TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA:
			return false

	var certificaciones: Array[String] = [
		TipoResultadoAnalisis.CERTIFICACION_PENDIENTE,
		TipoResultadoAnalisis.CERTIFICACION_SOLVENCIA,
		TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA,
		TipoResultadoAnalisis.CERTIFICACION_IMPOSIBILIDAD,
		TipoResultadoAnalisis.CERTIFICACION_INCOMPLETA
	]

	if catalogo.certificacion not in certificaciones:
		return false

	var tipos_recuento: Array[String] = [
		TipoResultadoAnalisis.RECUENTO_NO_DETERMINADO,
		TipoResultadoAnalisis.RECUENTO_EXACTO,
		TipoResultadoAnalisis.RECUENTO_BANDA,
		TipoResultadoAnalisis.RECUENTO_LIMITE_INFERIOR
	]

	if catalogo.tipo_recuento not in tipos_recuento:
		return false

	if catalogo.soluciones_minimas < 0:
		return false

	if catalogo.soluciones_maximas < 0:
		return false

	if catalogo.recuento_exacto < -1:
		return false

	if catalogo.tipo_recuento == TipoResultadoAnalisis.RECUENTO_EXACTO:
		if catalogo.recuento_exacto < 0:
			return false

		if catalogo.soluciones_minimas != catalogo.recuento_exacto:
			return false

		if catalogo.soluciones_maximas != catalogo.recuento_exacto:
			return false

	elif catalogo.recuento_exacto != -1:
		return false

	if catalogo.soluciones_maximas > 0:
		if catalogo.soluciones_minimas > catalogo.soluciones_maximas:
			return false

	if catalogo.tiempo_analisis_segundos < 0:
		return false

	if catalogo.nodos_explorados < 0:
		return false

	if catalogo.certificacion == TipoResultadoAnalisis.CERTIFICACION_IMPOSIBILIDAD:
		if not catalogo.recorridos_referencia.is_empty():
			return false

	if catalogo.certificacion == TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA:
		if not catalogo.cobertura_completa:
			return false

	if catalogo.validacion_independiente_superada:
		if catalogo.recorridos_referencia.is_empty():
			return false

	for recorrido in catalogo.recorridos_referencia:
		if recorrido.size() != catalogo.filas * catalogo.columnas:
			return false

		var posiciones_visitadas: Dictionary = {}

		for indice in range(recorrido.size()):
			var posicion: Vector2i = recorrido[indice]

			if posicion.x < 0 or posicion.x >= catalogo.columnas:
				return false

			if posicion.y < 0 or posicion.y >= catalogo.filas:
				return false

			if posiciones_visitadas.has(posicion):
				return false

			posiciones_visitadas[posicion] = true

			if indice > 0:
				var anterior: Vector2i = recorrido[indice - 1]
				var diferencia: Vector2i = posicion - anterior

				var horizontal: bool = (
					abs(diferencia.x) == 3 and diferencia.y == 0
				)

				var vertical: bool = (
					abs(diferencia.y) == 3 and diferencia.x == 0
				)

				var diagonal: bool = (
					abs(diferencia.x) == 2 and abs(diferencia.y) == 2
				)

				if not (horizontal or vertical or diagonal):
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

	pass
