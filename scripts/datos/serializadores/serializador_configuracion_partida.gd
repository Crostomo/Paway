
class_name SerializadorConfiguracionPartida
extends RefCounted

const VERSION_FORMATO: int = 1

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
		"filas": configuracion.filas,
		"columnas": configuracion.columnas,
		"inicio_permitido": _coordenadas_a_datos(
			configuracion.inicio_permitido
		),
		"final_permitido": _coordenadas_a_datos(
			configuracion.final_permitido
		),
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

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var campos_texto: Array[String] = [
		"id_partida",
		"tipo_partida",
        "id_reto"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO: " + campo)

	var campos_enteros: Array[String] = [
		"filas",
        "columnas"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO: " + campo)

	var campos_booleanos: Array[String] = [
		"usar_cronometro",
        "usar_pistas"
	]

	for campo in campos_booleanos:
		if not datos.has(campo) or not (datos[campo] is bool):
			return _error("CAMPO_BOOLEANO_NO_VALIDO: " + campo)

	if not datos.has("inicio_permitido") or not (
		datos["inicio_permitido"] is Array
	):
		return _error("INICIOS_NO_VALIDOS")

	if not datos.has("final_permitido") or not (
		datos["final_permitido"] is Array
	):
		return _error("FINALES_NO_VALIDOS")

	var resultado_inicios := _datos_a_coordenadas(
		datos["inicio_permitido"]
	)

	if not resultado_inicios.aceptado:
		return resultado_inicios

	var resultado_finales := _datos_a_coordenadas(
		datos["final_permitido"]
	)

	if not resultado_finales.aceptado:
		return resultado_finales

	var configuracion := TipoConfiguracionPartida.new()

	configuracion.id_partida = datos["id_partida"]
	configuracion.tipo_partida = datos["tipo_partida"]
	configuracion.filas = datos["filas"]
	configuracion.columnas = datos["columnas"]
	configuracion.inicio_permitido = resultado_inicios.datos["coordenadas"]
	configuracion.final_permitido = resultado_finales.datos["coordenadas"]
	configuracion.id_reto = datos["id_reto"]
	configuracion.usar_cronometro = datos["usar_cronometro"]
	configuracion.usar_pistas = datos["usar_pistas"]

	var resultado_validacion := TipoValidadorConfiguracion.validar(
		configuracion
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"configuracion": configuracion}
	)


static func _coordenadas_a_datos(
	coordenadas: Array[Vector2i]
) -> Array[Dictionary]:

	var resultado: Array[Dictionary] = []

	for coordenada in coordenadas:
		resultado.append({
			"x": coordenada.x,
			"y": coordenada.y
		})

	return resultado


static func _datos_a_coordenadas(
	datos: Array
) -> TipoResultadoOperacion:

	var coordenadas: Array[Vector2i] = []

	for elemento in datos:
		if not (elemento is Dictionary):
			return _error("COORDENADA_NO_VALIDA")

		if not elemento.has("x") or not elemento.has("y"):
			return _error("COORDENADA_INCOMPLETA")

		if not (elemento["x"] is int) or not (elemento["y"] is int):
			return _error("VALORES_COORDENADA_NO_VALIDOS")

		coordenadas.append(
			Vector2i(elemento["x"], elemento["y"])
		)

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"coordenadas": coordenadas}
	)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
