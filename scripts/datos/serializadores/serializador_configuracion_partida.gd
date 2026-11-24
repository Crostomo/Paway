
class_name SerializadorConfiguracionPartida
extends RefCounted

const VERSION_FORMATO: int = 3
const VERSION_FORMATO_ANTERIOR: int = 2

const TipoConfiguracionPartida = preload(
        "res://scripts/datos/modelos/configuracion_partida.gd"
)
const TipoResultadoOperacion = preload(
        "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorConfiguracion = preload(
        "res://scripts/datos/validadores/validador_configuracion_partida.gd"
)


static func serializar(
		configuracion: TipoConfiguracionPartida
) -> TipoResultadoOperacion:

		var resultado_validacion := TipoValidadorConfiguracion.validar(
				configuracion
		)

		if not resultado_validacion.aceptado:
				return resultado_validacion

		var datos: Dictionary = {
				"version_formato": VERSION_FORMATO,
				"id_partida": configuracion.id_partida,
				"tipo_partida": configuracion.tipo_partida,

				"id_geometria": configuracion.id_geometria,
				"version_geometria": configuracion.version_geometria,

				"id_reglas_movimiento": configuracion.id_reglas_movimiento,
				"version_reglas_movimiento": configuracion.version_reglas_movimiento,

				"filas": configuracion.filas,
				"columnas": configuracion.columnas,

				"inicio_permitido": configuracion.inicio_permitido.duplicate(),
				"final_permitido": configuracion.final_permitido.duplicate(),

				"id_reto": configuracion.id_reto,
				"usar_cronometro": configuracion.usar_cronometro,
				"usar_pistas": configuracion.usar_pistas
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

		var version_formato: int = datos["version_formato"]

		if version_formato != VERSION_FORMATO and version_formato != VERSION_FORMATO_ANTERIOR:
				return _error("VERSION_FORMATO_NO_COMPATIBLE")

		# Comprobar campos de texto.
		var campos_texto: Array[String] = [
				"id_partida",
				"tipo_partida",
				"id_geometria",
				"id_reglas_movimiento",
                "id_reto"
		]

		for campo in campos_texto:
				if not datos.has(campo) or not (datos[campo] is String):
						return _error("CAMPO_TEXTO_NO_VALIDO: " + campo)

		# Comprobar campos enteros.
		var campos_enteros: Array[String] = [
				"version_geometria",
				"version_reglas_movimiento",
				"filas",
                "columnas"
		]

		for campo in campos_enteros:
				if not datos.has(campo) or not (datos[campo] is int):
						return _error("CAMPO_ENTERO_NO_VALIDO: " + campo)

		# Comprobar campos booleanos.
		var campos_booleanos: Array[String] = [
				"usar_cronometro",
                "usar_pistas"
		]

		for campo in campos_booleanos:
				if not datos.has(campo) or not (datos[campo] is bool):
						return _error("CAMPO_BOOLEANO_NO_VALIDO: " + campo)

		# Comprobar que las restricciones son arrays.
		if not datos.has("inicio_permitido") or not (
				datos["inicio_permitido"] is Array
		):
				return _error("INICIOS_NO_VALIDOS")

		if not datos.has("final_permitido") or not (
				datos["final_permitido"] is Array
		):
				return _error("FINALES_NO_VALIDOS")

		# Convertir las restricciones según la versión de origen.
		var resultado_inicios: TipoResultadoOperacion
		var resultado_finales: TipoResultadoOperacion

		if version_formato == VERSION_FORMATO_ANTERIOR:

				resultado_inicios = _coordenadas_v2_a_ids(
						datos["inicio_permitido"],
						datos["filas"],
						datos["columnas"],
                        "INICIO"
				)

				if not resultado_inicios.aceptado:
						return resultado_inicios

				resultado_finales = _coordenadas_v2_a_ids(
						datos["final_permitido"],
						datos["filas"],
						datos["columnas"],
                        "FINAL"
				)

		else:

				resultado_inicios = _datos_a_ids(
						datos["inicio_permitido"],
                        "INICIOS_NO_VALIDOS"
				)

				if not resultado_inicios.aceptado:
						return resultado_inicios

				resultado_finales = _datos_a_ids(
						datos["final_permitido"],
                        "FINALES_NO_VALIDOS"
				)

		if not resultado_finales.aceptado:
				return resultado_finales

		# Reconstruir la configuracion.
		var configuracion := TipoConfiguracionPartida.new()

		configuracion.id_partida = datos["id_partida"]
		configuracion.tipo_partida = datos["tipo_partida"]

		configuracion.id_geometria = datos["id_geometria"]
		configuracion.version_geometria = datos["version_geometria"]

		configuracion.id_reglas_movimiento = datos["id_reglas_movimiento"]
		configuracion.version_reglas_movimiento = datos["version_reglas_movimiento"]

		configuracion.filas = datos["filas"]
		configuracion.columnas = datos["columnas"]

		configuracion.inicio_permitido = resultado_inicios.datos["ids"]
		configuracion.final_permitido = resultado_finales.datos["ids"]

		configuracion.id_reto = datos["id_reto"]
		configuracion.usar_cronometro = datos["usar_cronometro"]
		configuracion.usar_pistas = datos["usar_pistas"]

		# Validar la configuracion completa, incluidos los IDs.
		var resultado_validacion := TipoValidadorConfiguracion.validar(
				configuracion
		)

		if not resultado_validacion.aceptado:
				return resultado_validacion

		return TipoResultadoOperacion.crear_correcto(
				TipoResultadoOperacion.CODIGO_CORRECTO,
				{"configuracion": configuracion}
		)


static func _datos_a_ids(
		datos: Array,
		motivo: String
) -> TipoResultadoOperacion:

		var ids: Array[int] = []

		for elemento in datos:
				if not (elemento is int):
						return _error(motivo)

				ids.append(elemento)

		return TipoResultadoOperacion.crear_correcto(
				TipoResultadoOperacion.CODIGO_CORRECTO,
				{"ids": ids}
		)


static func _coordenadas_v2_a_ids(
		datos: Array,
		filas: int,
		columnas: int,
		tipo: String
) -> TipoResultadoOperacion:

		var ids: Array[int] = []

		for elemento in datos:

				if not (elemento is Dictionary):
						return _error(tipo + "_COORDENADA_NO_VALIDA")

				if not elemento.has("x") or not elemento.has("y"):
						return _error(tipo + "_COORDENADA_INCOMPLETA")

				if not (elemento["x"] is int) or not (elemento["y"] is int):
						return _error(tipo + "_VALORES_COORDENADA_NO_VALIDOS")

				var columna: int = elemento["x"]
				var fila: int = elemento["y"]

				if columna < 0 or columna >= columnas:
						return _error(tipo + "_FUERA_TABLERO")

				if fila < 0 or fila >= filas:
						return _error(tipo + "_FUERA_TABLERO")

				ids.append(fila * columnas + columna)

		return TipoResultadoOperacion.crear_correcto(
				TipoResultadoOperacion.CODIGO_CORRECTO,
				{"ids": ids}
		)


static func _error(motivo: String) -> TipoResultadoOperacion:
		return TipoResultadoOperacion.crear_error(
				TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
				{"motivo": motivo}
		)
