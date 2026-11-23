
class_name SerializadorRegistroMovimiento
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func serializar(
	registro: TipoRegistroMovimiento
) -> TipoResultadoOperacion:

	if registro == null:
		return _error("REGISTRO_NULO")

	if registro.numero < 1:
		return _error("NUMERO_MOVIMIENTO_NO_VALIDO")

	if registro.destino.x < 0 or registro.destino.y < 0:
		return _error("DESTINO_NO_VALIDO")

	if registro.es_primer_movimiento:
		if registro.numero != 1:
			return _error("PRIMER_MOVIMIENTO_INCORRECTO")
	else:
		if registro.numero == 1:
			return _error("PRIMER_MOVIMIENTO_NO_IDENTIFICADO")

		if registro.origen.x < 0 or registro.origen.y < 0:
			return _error("ORIGEN_NO_VALIDO")

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"numero": registro.numero,
		"origen": {
			"x": registro.origen.x,
			"y": registro.origen.y
		},
		"destino": {
			"x": registro.destino.x,
			"y": registro.destino.y
		},
		"es_primer_movimiento": registro.es_primer_movimiento
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

	if not datos.has("numero") or not (datos["numero"] is int):
		return _error("NUMERO_NO_VALIDO")

	if not datos.has("es_primer_movimiento") or not (
		datos["es_primer_movimiento"] is bool
	):
		return _error("MARCADOR_PRIMER_MOVIMIENTO_NO_VALIDO")

	if not datos.has("origen") or not (datos["origen"] is Dictionary):
		return _error("ORIGEN_NO_VALIDO")

	if not datos.has("destino") or not (datos["destino"] is Dictionary):
		return _error("DESTINO_NO_VALIDO")

	var resultado_origen := _leer_coordenada(datos["origen"])

	if not resultado_origen.aceptado:
		return resultado_origen

	var resultado_destino := _leer_coordenada(datos["destino"])

	if not resultado_destino.aceptado:
		return resultado_destino

	var registro := TipoRegistroMovimiento.new()

	registro.numero = datos["numero"]
	registro.origen = resultado_origen.datos["coordenada"]
	registro.destino = resultado_destino.datos["coordenada"]
	registro.es_primer_movimiento = datos["es_primer_movimiento"]

	if registro.numero < 1:
		return _error("NUMERO_MOVIMIENTO_NO_VALIDO")

	if registro.es_primer_movimiento:
		if registro.numero != 1:
			return _error("PRIMER_MOVIMIENTO_INCORRECTO")
	else:
		if registro.numero == 1:
			return _error("PRIMER_MOVIMIENTO_NO_IDENTIFICADO")

		if registro.origen.x < 0 or registro.origen.y < 0:
			return _error("ORIGEN_NO_VALIDO")

	if registro.destino.x < 0 or registro.destino.y < 0:
		return _error("DESTINO_NO_VALIDO")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"registro": registro}
	)


static func _leer_coordenada(
	datos: Dictionary
) -> TipoResultadoOperacion:

	if not datos.has("x") or not datos.has("y"):
		return _error("COORDENADA_INCOMPLETA")

	if not (datos["x"] is int) or not (datos["y"] is int):
		return _error("VALORES_COORDENADA_NO_VALIDOS")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{
			"coordenada": Vector2i(
				datos["x"],
				datos["y"]
			)
		}
	)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
