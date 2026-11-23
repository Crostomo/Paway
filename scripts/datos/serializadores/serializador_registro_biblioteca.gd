
class_name SerializadorRegistroBiblioteca
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoRegistroBiblioteca = preload(
    "res://scripts/datos/modelos/registro_biblioteca.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func serializar(
	registro: TipoRegistroBiblioteca
) -> TipoResultadoOperacion:

	if not _validar_registro(registro):
		return _error("REGISTRO_BIBLIOTECA_NO_VALIDO")

	var recorrido_serializado: Array[Dictionary] = []

	for posicion in registro.recorrido:
		recorrido_serializado.append({
			"x": posicion.x,
			"y": posicion.y
		})

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"id_recorrido": registro.id_recorrido,
		"tipo_partida": registro.tipo_partida,
		"id_reto": registro.id_reto,
		"filas": registro.filas,
		"columnas": registro.columnas,
		"recorrido": recorrido_serializado,
		"fecha_completado": registro.fecha_completado,
		"tiempo_segundos": registro.tiempo_segundos,
		"movimientos_realizados": registro.movimientos_realizados,
		"movimientos_deshechos": registro.movimientos_deshechos,
		"movimientos_efectivos": registro.movimientos_efectivos,
		"pistas_utilizadas": registro.pistas_utilizadas,
		"favorito": registro.favorito
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
		"id_recorrido",
		"tipo_partida",
		"id_reto",
        "fecha_completado"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

	var campos_enteros: Array[String] = [
		"filas",
		"columnas",
		"movimientos_realizados",
		"movimientos_deshechos",
		"movimientos_efectivos",
        "pistas_utilizadas"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO", {"campo": campo})

	if not datos.has("tiempo_segundos"):
		return _error("FALTA_TIEMPO")

	if not _es_numero(datos["tiempo_segundos"]):
		return _error("TIEMPO_NO_VALIDO")

	if not datos.has("favorito") or not (datos["favorito"] is bool):
		return _error("FAVORITO_NO_VALIDO")

	if not datos.has("recorrido") or not (datos["recorrido"] is Array):
		return _error("RECORRIDO_NO_VALIDO")

	var registro := TipoRegistroBiblioteca.new()

	registro.version_formato = VERSION_FORMATO
	registro.id_recorrido = datos["id_recorrido"]
	registro.tipo_partida = datos["tipo_partida"]
	registro.id_reto = datos["id_reto"]
	registro.filas = datos["filas"]
	registro.columnas = datos["columnas"]
	registro.fecha_completado = datos["fecha_completado"]
	registro.tiempo_segundos = float(datos["tiempo_segundos"])
	registro.movimientos_realizados = datos["movimientos_realizados"]
	registro.movimientos_deshechos = datos["movimientos_deshechos"]
	registro.movimientos_efectivos = datos["movimientos_efectivos"]
	registro.pistas_utilizadas = datos["pistas_utilizadas"]
	registro.favorito = datos["favorito"]

	for posicion in datos["recorrido"]:
		if not (posicion is Dictionary):
			return _error("POSICION_RECORRIDO_NO_VALIDA")

		if not posicion.has("x") or not (posicion["x"] is int):
			return _error("COORDENADA_X_NO_VALIDA")

		if not posicion.has("y") or not (posicion["y"] is int):
			return _error("COORDENADA_Y_NO_VALIDA")

		registro.recorrido.append(
			Vector2i(posicion["x"], posicion["y"])
		)

	if not _validar_registro(registro):
		return _error("REGISTRO_BIBLIOTECA_NO_VALIDO")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"registro": registro}
	)


static func _validar_registro(
	registro: TipoRegistroBiblioteca
) -> bool:

	if registro == null:
		return false

	if registro.version_formato != VERSION_FORMATO:
		return false

	if registro.id_recorrido.strip_edges().is_empty():
		return false

	if registro.tipo_partida not in ["normal", "personalizada", "reto"]:
		return false

	if registro.tipo_partida == "reto" and registro.id_reto.is_empty():
		return false

	if registro.filas < 5 or registro.columnas < 5:
		return false

	if registro.filas * registro.columnas > 500:
		return false

	if registro.recorrido.size() != registro.filas * registro.columnas:
		return false

	if registro.fecha_completado.is_empty():
		return false

	if registro.tiempo_segundos < 0:
		return false

	if registro.movimientos_realizados < 0:
		return false

	if registro.movimientos_deshechos < 0:
		return false

	if registro.movimientos_efectivos < 0:
		return false

	if registro.movimientos_efectivos != (
		registro.movimientos_realizados
		- registro.movimientos_deshechos
	):
		return false

	if registro.movimientos_efectivos != registro.filas * registro.columnas:
		return false

	if registro.pistas_utilizadas < 0:
		return false

	var posiciones_visitadas: Dictionary = {}

	for indice in range(registro.recorrido.size()):
		var posicion: Vector2i = registro.recorrido[indice]

		if posicion.x < 0 or posicion.x >= registro.columnas:
			return false

		if posicion.y < 0 or posicion.y >= registro.filas:
			return false

		if posiciones_visitadas.has(posicion):
			return false

		posiciones_visitadas[posicion] = true

		if indice > 0:
			var anterior: Vector2i = registro.recorrido[indice - 1]
			var diferencia: Vector2i = posicion - anterior

			var movimiento_horizontal: bool = (
				abs(diferencia.x) == 3 and diferencia.y == 0
			)

			var movimiento_vertical: bool = (
				abs(diferencia.y) == 3 and diferencia.x == 0
			)

			var movimiento_diagonal: bool = (
				abs(diferencia.x) == 2 and abs(diferencia.y) == 2
			)

			if not (
				movimiento_horizontal
				or movimiento_vertical
				or movimiento_diagonal
			):
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
