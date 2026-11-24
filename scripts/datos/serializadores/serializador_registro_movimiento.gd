
class_name SerializadorRegistroMovimiento
extends RefCounted

const VERSION_FORMATO: int = 2

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

	if registro.destino_id < 0:
		return _error("DESTINO_NO_VALIDO")

	if registro.es_primer_movimiento:
		if registro.numero != 1:
			return _error("PRIMER_MOVIMIENTO_INCORRECTO")

		if registro.origen_id != -1:
			return _error("ORIGEN_PRIMER_MOVIMIENTO_INCORRECTO")
	else:
		if registro.numero == 1:
			return _error("PRIMER_MOVIMIENTO_NO_IDENTIFICADO")

		if registro.origen_id < 0:
			return _error("ORIGEN_NO_VALIDO")

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"numero": registro.numero,
		"origen_id": registro.origen_id,
		"destino_id": registro.destino_id,
		"es_primer_movimiento": registro.es_primer_movimiento
	}

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"datos": datos}
	)


static func deserializar(
	datos: Dictionary
) -> TipoResultadoOperacion:

	if not datos.has("version_formato"):
		return _error("FALTA_VERSION_FORMATO")

	if not (datos["version_formato"] is int):
		return _error("VERSION_FORMATO_NO_VALIDA")

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var campos_enteros: Array[String] = [
		"numero",
		"origen_id",
		"destino_id"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO: " + campo)

	if not datos.has("es_primer_movimiento"):
		return _error("MARCADOR_PRIMER_MOVIMIENTO_NO_VALIDO")

	if not (datos["es_primer_movimiento"] is bool):
		return _error("MARCADOR_PRIMER_MOVIMIENTO_NO_VALIDO")

	var registro := TipoRegistroMovimiento.new()

	registro.numero = datos["numero"]
	registro.origen_id = datos["origen_id"]
	registro.destino_id = datos["destino_id"]
	registro.es_primer_movimiento = datos["es_primer_movimiento"]

	if registro.numero < 1:
		return _error("NUMERO_MOVIMIENTO_NO_VALIDO")

	if registro.destino_id < 0:
		return _error("DESTINO_NO_VALIDO")

	if registro.es_primer_movimiento:
		if registro.numero != 1:
			return _error("PRIMER_MOVIMIENTO_INCORRECTO")

		if registro.origen_id != -1:
			return _error("ORIGEN_PRIMER_MOVIMIENTO_INCORRECTO")
	else:
		if registro.numero == 1:
			return _error("PRIMER_MOVIMIENTO_NO_IDENTIFICADO")

		if registro.origen_id < 0:
			return _error("ORIGEN_NO_VALIDO")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"registro": registro}
	)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
