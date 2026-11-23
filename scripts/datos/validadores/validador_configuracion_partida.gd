
class_name ValidadorConfiguracionPartida
extends RefCounted

const TipoConfiguracionPartida = preload(
    "res://scripts/datos/modelos/configuracion_partida.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorDimensiones = preload(
    "res://scripts/datos/validadores/validador_dimensiones_tablero.gd"
)


static func validar(
    configuracion: TipoConfiguracionPartida
) -> TipoResultadoOperacion:

    if configuracion == null:
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {"motivo": "CONFIGURACION_NULA"}
        )

    var resultado_dimensiones := TipoValidadorDimensiones.validar(
        configuracion.filas,
        configuracion.columnas
    )

    if not resultado_dimensiones.aceptado:
        return resultado_dimensiones

    if not [
        TipoConfiguracionPartida.TIPO_NORMAL,
        TipoConfiguracionPartida.TIPO_PERSONALIZADA,
        TipoConfiguracionPartida.TIPO_RETO
    ].has(configuracion.tipo_partida):
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {"motivo": "TIPO_PARTIDA_NO_VALIDO"}
        )

    if configuracion.tipo_partida == TipoConfiguracionPartida.TIPO_RETO:
        if configuracion.id_reto.strip_edges().is_empty():
            return TipoResultadoOperacion.crear_error(
                TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
                {"motivo": "RETO_SIN_IDENTIFICADOR"}
            )
    elif not configuracion.id_reto.is_empty():
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {"motivo": "IDENTIFICADOR_RETO_NO_CORRESPONDE"}
        )

    var total_casillas: int = configuracion.filas * configuracion.columnas

    var resultado_inicio := _validar_restricciones(
        configuracion.inicio_permitido,
        configuracion.filas,
        configuracion.columnas,
        "INICIO"
    )

    if not resultado_inicio.aceptado:
        return resultado_inicio

    var resultado_final := _validar_restricciones(
        configuracion.final_permitido,
        configuracion.filas,
        configuracion.columnas,
        "FINAL"
    )

    if not resultado_final.aceptado:
        return resultado_final

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO,
        {"total_casillas": total_casillas}
    )


static func _validar_restricciones(
    casillas: Array[Vector2i],
    filas: int,
    columnas: int,
    tipo: String
) -> TipoResultadoOperacion:

    var casillas_vistas: Dictionary = {}

    for casilla in casillas:
        var columna: int = casilla.x
        var fila: int = casilla.y

        if fila < 0 or fila >= filas or columna < 0 or columna >= columnas:
            return TipoResultadoOperacion.crear_error(
                TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
                {"motivo": tipo + "_FUERA_TABLERO"}
            )

        if casillas_vistas.has(casilla):
            return TipoResultadoOperacion.crear_error(
                TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
                {"motivo": tipo + "_DUPLICADO"}
            )

        casillas_vistas[casilla] = true

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO
    )
