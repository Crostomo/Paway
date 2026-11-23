
class_name ValidadorDimensionesTablero
extends RefCounted

const MINIMO_FILAS: int = 5
const MINIMO_COLUMNAS: int = 5
const MAXIMO_CASILLAS: int = 500

const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func validar(filas: int, columnas: int) -> TipoResultadoOperacion:
    if filas < MINIMO_FILAS:
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {"motivo": "FILAS_INSUFICIENTES"}
        )

    if columnas < MINIMO_COLUMNAS:
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {"motivo": "COLUMNAS_INSUFICIENTES"}
        )

    var total_casillas: int = filas * columnas

    if total_casillas > MAXIMO_CASILLAS:
        return TipoResultadoOperacion.crear_error(
            TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
            {
                "motivo": "DEMASIADAS_CASILLAS",
                "total_casillas": total_casillas,
                "maximo_permitido": MAXIMO_CASILLAS
            }
        )

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO,
        {
            "filas": filas,
            "columnas": columnas,
            "total_casillas": total_casillas
        }
    )
