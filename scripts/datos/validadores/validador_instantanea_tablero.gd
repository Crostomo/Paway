
class_name ValidadorInstantaneaTablero
extends RefCounted

const VERSION_FORMATO_COMPATIBLE: int = 2

const TipoInstantaneaTablero = preload(
	"res://scripts/datos/modelos/instantanea_tablero.gd"
)
const TipoEstadoTablero = preload(
	"res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoResultadoOperacion = preload(
	"res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorEstado = preload(
	"res://scripts/datos/validadores/validador_estado_tablero.gd"
)


static func validar(
	instantanea: TipoInstantaneaTablero
) -> TipoResultadoOperacion:

	if instantanea == null:
		return _error("INSTANTANEA_NULA")

	if instantanea.version_formato != VERSION_FORMATO_COMPATIBLE:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

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

	return TipoValidadorEstado.validar(estado)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
