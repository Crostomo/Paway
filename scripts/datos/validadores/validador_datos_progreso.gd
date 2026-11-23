
class_name ValidadorDatosProgreso
extends RefCounted

const TipoDatosProgreso = preload(
    "res://scripts/datos/modelos/datos_progreso.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)

const VERSION_FORMATO_ADMITIDA: int = 1
const NIVEL_MINIMO: int = 1


static func validar(
    progreso: TipoDatosProgreso
) -> TipoResultadoOperacion:

    if progreso == null:
        return _error("PROGRESO_NULO")

    if progreso.version_formato != VERSION_FORMATO_ADMITIDA:
        return _error("VERSION_FORMATO_NO_COMPATIBLE")

    if progreso.experiencia_total < 0:
        return _error("EXPERIENCIA_NEGATIVA")

    if progreso.nivel_actual < NIVEL_MINIMO:
        return _error("NIVEL_NO_VALIDO")

    var recompensas_vistas: Dictionary = {}

    for id_recompensa in progreso.recompensas_concedidas:
        if id_recompensa.strip_edges().is_empty():
            return _error("IDENTIFICADOR_RECOMPENSA_VACIO")

        if recompensas_vistas.has(id_recompensa):
            return _error("RECOMPENSA_DUPLICADA")

        recompensas_vistas[id_recompensa] = true

    var dimensiones_vistas: Dictionary = {}

    for dimensiones in progreso.dimensiones_completadas:
        if not _validar_formato_dimensiones(dimensiones):
            return _error("FORMATO_DIMENSIONES_NO_VALIDO")

        if dimensiones_vistas.has(dimensiones):
            return _error("DIMENSIONES_DUPLICADAS")

        dimensiones_vistas[dimensiones] = true

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO,
        {
            "experiencia_total": progreso.experiencia_total,
            "nivel_actual": progreso.nivel_actual,
            "recompensas_registradas": recompensas_vistas.size(),
            "dimensiones_completadas": dimensiones_vistas.size()
        }
    )


static func _validar_formato_dimensiones(valor: String) -> bool:
    var partes: PackedStringArray = valor.split("x")

    if partes.size() != 2:
        return false

    if not partes[0].is_valid_int() or not partes[1].is_valid_int():
        return false

    var filas: int = int(partes[0])
    var columnas: int = int(partes[1])

    if filas < 5 or columnas < 5:
        return false

    if filas * columnas > 500:
        return false

    return true


static func _error(motivo: String) -> TipoResultadoOperacion:
    return TipoResultadoOperacion.crear_error(
        TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        {"motivo": motivo}
    )
