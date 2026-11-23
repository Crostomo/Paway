
class_name SerializadorDatosProgreso
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoDatosProgreso = preload(
    "res://scripts/datos/modelos/datos_progreso.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorProgreso = preload(
    "res://scripts/datos/validadores/validador_datos_progreso.gd"
)


static func serializar(
	progreso: TipoDatosProgreso
) -> TipoResultadoOperacion:

	var resultado_validacion := TipoValidadorProgreso.validar(progreso)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"experiencia_total": progreso.experiencia_total,
		"nivel_actual": progreso.nivel_actual,
		"recompensas_concedidas": progreso.recompensas_concedidas.duplicate(),
		"dimensiones_completadas": progreso.dimensiones_completadas.duplicate(),
		"ultima_actualizacion": progreso.ultima_actualizacion
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

	var campos_obligatorios: Array[String] = [
		"experiencia_total",
		"nivel_actual",
		"recompensas_concedidas",
		"dimensiones_completadas",
        "ultima_actualizacion"
	]

	for campo in campos_obligatorios:
		if not datos.has(campo):
			return _error("FALTA_CAMPO", {"campo": campo})

	if not (datos["experiencia_total"] is int):
		return _error("EXPERIENCIA_NO_VALIDA")

	if not (datos["nivel_actual"] is int):
		return _error("NIVEL_NO_VALIDO")

	if not (datos["recompensas_concedidas"] is Array):
		return _error("RECOMPENSAS_NO_VALIDAS")

	if not (datos["dimensiones_completadas"] is Array):
		return _error("DIMENSIONES_NO_VALIDAS")

	if not (datos["ultima_actualizacion"] is String):
		return _error("FECHA_NO_VALIDA")

	var progreso := TipoDatosProgreso.new()

	progreso.version_formato = VERSION_FORMATO
	progreso.experiencia_total = datos["experiencia_total"]
	progreso.nivel_actual = datos["nivel_actual"]
	progreso.ultima_actualizacion = datos["ultima_actualizacion"]

	for recompensa in datos["recompensas_concedidas"]:
		if not (recompensa is String):
			return _error("RECOMPENSA_NO_VALIDA")

		progreso.recompensas_concedidas.append(recompensa)

	for dimension in datos["dimensiones_completadas"]:
		if not (dimension is String):
			return _error("DIMENSION_NO_VALIDA")

		progreso.dimensiones_completadas.append(dimension)

	var resultado_validacion := TipoValidadorProgreso.validar(progreso)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"progreso": progreso}
	)


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
