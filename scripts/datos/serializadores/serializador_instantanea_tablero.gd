
class_name SerializadorInstantaneaTablero
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoInstantaneaTablero = preload(
    "res://scripts/datos/modelos/instantanea_tablero.gd"
)
const TipoEstadoTablero = preload(
    "res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoSerializadorEstado = preload(
    "res://scripts/datos/serializadores/serializador_estado_tablero.gd"
)
const TipoValidadorInstantanea = preload(
    "res://scripts/datos/validadores/validador_instantanea_tablero.gd"
)


static func serializar(
	instantanea: TipoInstantaneaTablero
) -> TipoResultadoOperacion:

	var resultado_validacion := TipoValidadorInstantanea.validar(
		instantanea
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	var estado_temporal := TipoEstadoTablero.new()

	estado_temporal.filas = instantanea.filas
	estado_temporal.columnas = instantanea.columnas
	estado_temporal.matriz = instantanea.matriz.duplicate(true)
	estado_temporal.historial = instantanea.historial.duplicate(true)
	estado_temporal.ultima_casilla = instantanea.ultima_casilla
	estado_temporal.estado = instantanea.estado
	estado_temporal.movimientos_realizados = instantanea.movimientos_realizados
	estado_temporal.movimientos_deshechos = instantanea.movimientos_deshechos
	estado_temporal.movimientos_efectivos = instantanea.movimientos_efectivos

	var resultado_estado := TipoSerializadorEstado.serializar(
		estado_temporal
	)

	if not resultado_estado.aceptado:
		return resultado_estado

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"datos": resultado_estado.datos["datos"]}
	)


static func deserializar(datos: Dictionary) -> TipoResultadoOperacion:

	if not datos.has("version_formato"):
		return _error("FALTA_VERSION_FORMATO")

	if not (datos["version_formato"] is int):
		return _error("VERSION_FORMATO_NO_VALIDA")

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var resultado_estado := TipoSerializadorEstado.deserializar(datos)

	if not resultado_estado.aceptado:
		return resultado_estado

	var estado = resultado_estado.datos["estado_tablero"]
	var instantanea := TipoInstantaneaTablero.new()

	instantanea.version_formato = VERSION_FORMATO
	instantanea.filas = estado.filas
	instantanea.columnas = estado.columnas
	instantanea.matriz = estado.matriz.duplicate(true)
	instantanea.historial = estado.historial.duplicate(true)
	instantanea.ultima_casilla = estado.ultima_casilla
	instantanea.estado = estado.estado
	instantanea.movimientos_realizados = estado.movimientos_realizados
	instantanea.movimientos_deshechos = estado.movimientos_deshechos
	instantanea.movimientos_efectivos = estado.movimientos_efectivos

	var resultado_validacion := TipoValidadorInstantanea.validar(
		instantanea
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"instantanea": instantanea}
	)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
