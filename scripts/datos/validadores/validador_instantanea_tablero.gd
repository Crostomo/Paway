
class_name ValidadorInstantaneaTablero
extends RefCounted

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

    if instantanea.version_formato != TipoInstantaneaTablero.VERSION_FORMATO:
        return _error("VERSION_FORMATO_NO_COMPATIBLE")

    var estado_temporal := TipoEstadoTablero.new()

    estado_temporal.filas = instantanea.filas
    estado_temporal.columnas = instantanea.columnas
    estado_temporal.matriz = instantanea.matriz.duplicate(true)
    estado_temporal.historial = instantanea.historial.duplicate(true)
    estado_temporal.ultima_casilla = instantanea.ultima_casilla
    estado_temporal.estado = instantanea.estado
    estado_temporal.movimientos_realizados = instantanea.movimientos_realizados
    estado_temporal.movimientos_deshechados = instantanea.movimientos_deshechados
    estado_temporal.movimientos_efectivos = instantanea.movimientos_efectivos

    var resultado_estado := TipoValidadorEstado.validar(estado_temporal)

    if not resultado_estado.aceptado:
        return resultado_estado

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO,
        {
            "filas": instantanea.filas,
            "columnas": instantanea.columnas
        }
    )


static func _error(motivo: String) -> TipoResultadoOperacion:
    return TipoResultadoOperacion.crear_error(
        TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        {"motivo": motivo}
    )
