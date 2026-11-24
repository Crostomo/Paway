
class_name SerializadorInstantaneaTablero
extends RefCounted

const VERSION_FORMATO: int = 2

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

	if instantanea == null:
		return _error("INSTANTANEA_NULA")

	var resultado_validacion := TipoValidadorInstantanea.validar(
		instantanea
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	var estado := _crear_estado_desde_instantanea(instantanea)

	var resultado_estado := TipoSerializadorEstado.serializar(estado)

	if not resultado_estado.aceptado:
		return resultado_estado

	var datos: Dictionary = resultado_estado.datos["datos"].duplicate(
		true
	)

	datos["version_formato"] = VERSION_FORMATO

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

	var resultado_estado := TipoSerializadorEstado.deserializar(datos)

	if not resultado_estado.aceptado:
		return resultado_estado

	var estado: TipoEstadoTablero = (
		resultado_estado.datos["estado_tablero"]
	)

	var instantanea := _crear_instantanea_desde_estado(estado)

	var resultado_validacion := TipoValidadorInstantanea.validar(
		instantanea
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"instantanea": instantanea}
	)


static func _crear_estado_desde_instantanea(
	instantanea: TipoInstantaneaTablero
) -> TipoEstadoTablero:

	var estado := TipoEstadoTablero.new()

	estado.id_geometria = instantanea.id_geometria
	estado.version_geometria = instantanea.version_geometria
	estado.id_reglas_movimiento = instantanea.id_reglas_movimiento
	estado.version_reglas_movimiento = (
		instantanea.version_reglas_movimiento
	)

	estado.filas = instantanea.filas
	estado.columnas = instantanea.columnas
	estado.matriz = instantanea.matriz.duplicate(true)
	estado.historial = instantanea.historial.duplicate(true)
	estado.ultima_casilla_id = instantanea.ultima_casilla_id
	estado.estado = instantanea.estado

	estado.movimientos_realizados = instantanea.movimientos_realizados
	estado.movimientos_deshechos = instantanea.movimientos_deshechos
	estado.movimientos_efectivos = instantanea.movimientos_efectivos

	return estado


static func _crear_instantanea_desde_estado(
	estado: TipoEstadoTablero
) -> TipoInstantaneaTablero:

	var instantanea := TipoInstantaneaTablero.new()

	instantanea.version_formato = VERSION_FORMATO

	instantanea.id_geometria = estado.id_geometria
	instantanea.version_geometria = estado.version_geometria
	instantanea.id_reglas_movimiento = estado.id_reglas_movimiento
	instantanea.version_reglas_movimiento = (
		estado.version_reglas_movimiento
	)

	instantanea.filas = estado.filas
	instantanea.columnas = estado.columnas
	instantanea.matriz = estado.matriz.duplicate(true)
	instantanea.historial = estado.historial.duplicate(true)
	instantanea.ultima_casilla_id = estado.ultima_casilla_id
	instantanea.estado = estado.estado

	instantanea.movimientos_realizados = estado.movimientos_realizados
	instantanea.movimientos_deshechos = estado.movimientos_deshechos
	instantanea.movimientos_efectivos = estado.movimientos_efectivos

	return instantanea


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
