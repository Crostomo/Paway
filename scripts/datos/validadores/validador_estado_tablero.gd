
class_name ValidadorEstadoTablero
extends RefCounted

const TipoEstadoTablero = preload(
    "res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorDimensiones = preload(
    "res://scripts/datos/validadores/validador_dimensiones_tablero.gd"
)

const DESPLAZAMIENTOS_PERMITIDOS: Array[Vector2i] = [
    Vector2i(-3, 0),
    Vector2i(3, 0),
    Vector2i(0, -3),
    Vector2i(0, 3),
    Vector2i(-2, -2),
    Vector2i(-2, 2),
    Vector2i(2, -2),
    Vector2i(2, 2)
]


static func validar(estado: TipoEstadoTablero) -> TipoResultadoOperacion:
    if estado == null:
        return _error("ESTADO_NULO")

    var resultado_dimensiones := TipoValidadorDimensiones.validar(
        estado.filas,
        estado.columnas
    )

    if not resultado_dimensiones.aceptado:
        return resultado_dimensiones

    if estado.matriz.size() != estado.filas:
        return _error("NUMERO_FILAS_INCORRECTO")

    var total_numeros: int = 0
    var numeros_vistos: Dictionary = {}
    var numero_maximo: int = 0
    var ultima_posicion_detectada := Vector2i(-1, -1)

    for fila in range(estado.filas):
        var fila_actual: Array = estado.matriz[fila]

        if fila_actual.size() != estado.columnas:
            return _error("NUMERO_COLUMNAS_INCORRECTO")

        for columna in range(estado.columnas):
            var valor: Variant = fila_actual[columna]

            if not (valor is int):
                return _error("VALOR_DE_CASILLA_NO_VALIDO")

            if valor < 0 or valor > estado.filas * estado.columnas:
                return _error("NUMERO_FUERA_DE_RANGO")

            if valor > 0:
                if numeros_vistos.has(valor):
                    return _error("NUMERO_REPETIDO")

                numeros_vistos[valor] = true
                total_numeros += 1

                if valor > numero_maximo:
                    numero_maximo = valor
                    ultima_posicion_detectada = Vector2i(
                        columna,
                        fila
                    )

    for numero in range(1, total_numeros + 1):
        if not numeros_vistos.has(numero):
            return _error("SECUENCIA_INCOMPLETA")

    if estado.historial.size() != total_numeros:
        return _error("HISTORIAL_NO_COINCIDE")

    if total_numeros == 0:
        if estado.ultima_casilla != Vector2i(-1, -1):
            return _error("ULTIMA_CASILLA_INCORRECTA")
    elif estado.ultima_casilla != ultima_posicion_detectada:
        return _error("ULTIMA_CASILLA_INCORRECTA")

    if estado.movimientos_realizados < 0:
        return _error("CONTADOR_REALIZADOS_NEGATIVO")

    if estado.movimientos_deshechos < 0:
        return _error("CONTADOR_DESHECHOS_NEGATIVO")

    if estado.movimientos_efectivos < 0:
        return _error("CONTADOR_EFECTIVOS_NEGATIVO")

    if estado.movimientos_efectivos != (
        estado.movimientos_realizados - estado.movimientos_deshechos
    ):
        return _error("CONTADORES_NO_COINCIDEN")

    if estado.movimientos_realizados < estado.movimientos_deshechos:
        return _error("DESHECHOS_SUPERAN_REALIZADOS")

    var estados_validos: Array[String] = [
        TipoEstadoTablero.ESTADO_PREPARADA,
        TipoEstadoTablero.ESTADO_ACTIVA,
        TipoEstadoTablero.ESTADO_BLOQUEADA,
        TipoEstadoTablero.ESTADO_COMPLETADA
    ]

    if not estados_validos.has(estado.estado):
        return _error("ESTADO_NO_RECONOCIDO")

    if estado.estado == TipoEstadoTablero.ESTADO_PREPARADA:
        if total_numeros != 0:
            return _error("PREPARADA_CON_MOVIMIENTOS")

    if estado.estado == TipoEstadoTablero.ESTADO_COMPLETADA:
        if total_numeros != estado.filas * estado.columnas:
            return _error("COMPLETADA_INCOMPLETA")

    if total_numeros > 0:
        var resultado_historial := _validar_historial(estado)

        if not resultado_historial.aceptado:
            return resultado_historial

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO,
        {"casillas_numeradas": total_numeros}
    )


static func _validar_historial(
    estado: TipoEstadoTablero
) -> TipoResultadoOperacion:

    var posicion_anterior := Vector2i(-1, -1)

    for indice in range(estado.historial.size()):
        var registro: Variant = estado.historial[indice]

        if registro == null:
            return _error("REGISTRO_NULO")

        if registro.numero != indice + 1:
            return _error("NUMERACION_HISTORIAL_INCORRECTA")

        var destino: Vector2i = registro.destino

        if destino.x < 0 or destino.x >= estado.columnas:
            return _error("DESTINO_HISTORIAL_FUERA_TABLERO")

        if destino.y < 0 or destino.y >= estado.filas:
            return _error("DESTINO_HISTORIAL_FUERA_TABLERO")

        if estado.matriz[destino.y][destino.x] != registro.numero:
            return _error("HISTORIAL_NO_COINCIDE_CON_MATRIZ")

        if indice == 0:
            if not registro.es_primer_movimiento:
                return _error("PRIMER_MOVIMIENTO_INCORRECTO")
        else:
            if registro.es_primer_movimiento:
                return _error("PRIMER_MOVIMIENTO_REPETIDO")

            if registro.origen != posicion_anterior:
                return _error("ORIGEN_HISTORIAL_INCORRECTO")

            var desplazamiento: Vector2i = destino - posicion_anterior

            if not DESPLAZAMIENTOS_PERMITIDOS.has(desplazamiento):
                return _error("DESPLAZAMIENTO_NO_PERMITIDO")

        posicion_anterior = destino

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO
    )


static func _error(motivo: String) -> TipoResultadoOperacion:
    return TipoResultadoOperacion.crear_error(
        TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        {"motivo": motivo}
    )
