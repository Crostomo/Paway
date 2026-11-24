
class_name SerializadorRegistroBiblioteca
extends RefCounted

const VERSION_FORMATO: int = 2
const VERSION_FORMATO_ANTERIOR: int = 1

const TipoRegistroBiblioteca = preload(
    "res://scripts/datos/modelos/registro_biblioteca.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoGeometriaTablero = preload(
    "res://scripts/datos/modelos/geometria_tablero.gd"
)
const TipoReglasMovimiento = preload(
    "res://scripts/datos/modelos/reglas_movimiento.gd"
)


static func serializar(
		registro: TipoRegistroBiblioteca
) -> TipoResultadoOperacion:

		if not _validar_registro(registro):
				return _error("REGISTRO_BIBLIOTECA_NO_VALIDO")

		var recorrido_serializado: Array[int] = []

		for id_casilla: int in registro.recorrido:
				recorrido_serializado.append(id_casilla)

		var datos: Dictionary = {
				"version_formato": VERSION_FORMATO,
				"id_geometria": registro.id_geometria,
				"version_geometria": registro.version_geometria,
				"id_reglas_movimiento": registro.id_reglas_movimiento,
				"version_reglas_movimiento": registro.version_reglas_movimiento,
				"id_recorrido": registro.id_recorrido,
				"tipo_partida": registro.tipo_partida,
				"id_reto": registro.id_reto,
				"filas": registro.filas,
				"columnas": registro.columnas,
				"recorrido": recorrido_serializado,
				"fecha_completado": registro.fecha_completado,
				"tiempo_segundos": registro.tiempo_segundos,
				"movimientos_realizados": registro.movimientos_realizados,
				"movimientos_deshechados": registro.movimientos_deshechados,
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

		var version_recibida: int = datos["version_formato"]

		if version_recibida != VERSION_FORMATO and version_recibida != VERSION_FORMATO_ANTERIOR:
				return _error("VERSION_FORMATO_NO_COMPATIBLE")

		var campos_texto: Array[String] = [
				"id_recorrido",
				"tipo_partida",
				"id_reto",
                "fecha_completado"
		]

		for campo: String in campos_texto:
				if not datos.has(campo) or not (datos[campo] is String):
						return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

		var campos_enteros: Array[String] = [
				"filas",
				"columnas",
				"movimientos_realizados",
				"movimientos_deshechados",
				"movimientos_efectivos",
                "pistas_utilizadas"
		]

		for campo: String in campos_enteros:
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

		var registro = TipoRegistroBiblioteca.new()

		registro.version_formato = VERSION_FORMATO
		registro.id_recorrido = datos["id_recorrido"]
		registro.tipo_partida = datos["tipo_partida"]
		registro.id_reto = datos["id_reto"]
		registro.filas = datos["filas"]
		registro.columnas = datos["columnas"]
		registro.fecha_completado = datos["fecha_completado"]
		registro.tiempo_segundos = float(datos["tiempo_segundos"])
		registro.movimientos_realizados = datos["movimientos_realizados"]
		registro.movimientos_deshechados = datos["movimientos_deshechados"]
		registro.movimientos_efectivos = datos["movimientos_efectivos"]
		registro.pistas_utilizadas = datos["pistas_utilizadas"]
		registro.favorito = datos["favorito"]

		if version_recibida == VERSION_FORMATO_ANTERIOR:
				# El formato anterior solo representaba tableros rectangulares.
				registro.id_geometria = "rectangular"
				registro.version_geometria = 1
				registro.id_reglas_movimiento = "rectangular_saltos_3_2"
				registro.version_reglas_movimiento = 1

				for posicion: Variant in datos["recorrido"]:
						if not (posicion is Dictionary):
								return _error("POSICION_RECORRIDO_NO_VALIDA")

						if not posicion.has("x") or not (posicion["x"] is int):
								return _error("COORDENADA_X_NO_VALIDA")

						if not posicion.has("y") or not (posicion["y"] is int):
								return _error("COORDENADA_Y_NO_VALIDA")

						var coordenada := Vector2i(
								posicion["x"],
								posicion["y"]
						)

						if coordenada.x < 0 or coordenada.x >= registro.columnas:
								return _error("COORDENADA_X_NO_VALIDA")

						if coordenada.y < 0 or coordenada.y >= registro.filas:
								return _error("COORDENADA_Y_NO_VALIDA")

						var id_casilla: int = (
								coordenada.y * registro.columnas
								+ coordenada.x
						)

						registro.recorrido.append(id_casilla)

		else:
				var campos_geometria: Array[String] = [
						"id_geometria",
                        "id_reglas_movimiento"
				]

				for campo: String in campos_geometria:
						if not datos.has(campo) or not (datos[campo] is String):
								return _error("IDENTIDAD_GEOMETRIA_NO_VALIDA", {"campo": campo})

				var campos_version: Array[String] = [
						"version_geometria",
                        "version_reglas_movimiento"
				]

				for campo: String in campos_version:
						if not datos.has(campo) or not (datos[campo] is int):
								return _error("VERSION_GEOMETRIA_NO_VALIDA", {"campo": campo})

				registro.id_geometria = datos["id_geometria"]
				registro.version_geometria = datos["version_geometria"]
				registro.id_reglas_movimiento = datos["id_reglas_movimiento"]
				registro.version_reglas_movimiento = datos["version_reglas_movimiento"]

				for id_casilla: Variant in datos["recorrido"]:
						if not (id_casilla is int):
								return _error("ID_CASILLA_NO_VALIDO")

						registro.recorrido.append(id_casilla)

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

		if registro.id_geometria != "rectangular":
				return false

		if registro.version_geometria != 1:
				return false

		if registro.id_reglas_movimiento != "rectangular_saltos_3_2":
				return false

		if registro.version_reglas_movimiento != 1:
				return false

		if registro.id_recorrido.strip_edges().is_empty():
				return false

		if registro.tipo_partida not in ["normal", "personalizada", "reto"]:
				return false

		if registro.tipo_partida == "reto" and registro.id_reto.strip_edges().is_empty():
				return false

		if registro.filas < 5 or registro.columnas < 5:
				return false

		if registro.filas * registro.columnas > 500:
				return false

		if registro.recorrido.size() != registro.filas * registro.columnas:
				return false

		if registro.fecha_completado.strip_edges().is_empty():
				return false

		if not is_finite(registro.tiempo_segundos):
			return false

		if registro.tiempo_segundos < 0:
				return false

		if registro.movimientos_realizados < 0:
				return false

		if registro.movimientos_deshechados < 0:
				return false

		if registro.movimientos_efectivos < 0:
				return false

		if registro.movimientos_efectivos != (
				registro.movimientos_realizados
				- registro.movimientos_deshechados
		):
				return false

		if registro.movimientos_efectivos != registro.filas * registro.columnas:
				return false

		if registro.pistas_utilizadas < 0:
				return false

		var geometria = TipoGeometriaTablero.new()

		if not geometria.configurar_rectangular(
				registro.filas,
				registro.columnas
		):
				return false

		var reglas = TipoReglasMovimiento.new()
		var casillas_visitadas: Dictionary = {}

		for indice: int in range(registro.recorrido.size()):
				var id_casilla: int = registro.recorrido[indice]

				if not geometria.contiene_id_casilla(id_casilla):
						return false

				if casillas_visitadas.has(id_casilla):
						return false

				casillas_visitadas[id_casilla] = true

				if indice > 0:
						var id_anterior: int = registro.recorrido[indice - 1]

						if not reglas.es_movimiento_valido(
								geometria,
								id_anterior,
								id_casilla
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
