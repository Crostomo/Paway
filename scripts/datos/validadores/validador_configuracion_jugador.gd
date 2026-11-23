
class_name ValidadorConfiguracionJugador
extends RefCounted

const TipoConfiguracionJugador = preload(
    "res://scripts/datos/modelos/configuracion_jugador.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)

const VERSION_FORMATO_ADMITIDA: int = 1

const TEMAS_ADMITIDOS: Array[String] = [
    "sistema",
    "claro",
    "oscuro",
    "colorido"
]

const ESTILOS_ADMITIDOS: Array[String] = [
    "clasico",
    "moderno",
    "minimalista"
]

const IDIOMAS_ADMITIDOS: Array[String] = [
    "automatico",
    "es",
    "en",
    "fr",
    "pt",
    "ca"
]


static func validar(
    configuracion: TipoConfiguracionJugador
) -> TipoResultadoOperacion:

    if configuracion == null:
        return _error("CONFIGURACION_NULA")

    if configuracion.version_formato != VERSION_FORMATO_ADMITIDA:
        return _error("VERSION_FORMATO_NO_COMPATIBLE")

    if not TEMAS_ADMITIDOS.has(configuracion.tema):
        return _error("TEMA_NO_ADMITIDO")

    if not ESTILOS_ADMITIDOS.has(configuracion.estilo_visual):
        return _error("ESTILO_NO_ADMITIDO")

    if not IDIOMAS_ADMITIDOS.has(configuracion.idioma):
        return _error("IDIOMA_NO_ADMITIDO")

    if configuracion.escala_texto < 0.75 or configuracion.escala_texto > 2.0:
        return _error("ESCALA_TEXTO_FUERA_DE_RANGO")

    if configuracion.tamano_numeros < 0.75 or configuracion.tamano_numeros > 2.0:
        return _error("TAMANO_NUMEROS_FUERA_DE_RANGO")

    if configuracion.tipografia.strip_edges().is_empty():
        return _error("TIPOGRAFIA_VACIA")

    return TipoResultadoOperacion.crear_correcto(
        TipoResultadoOperacion.CODIGO_CORRECTO
    )


static func _error(motivo: String) -> TipoResultadoOperacion:
    return TipoResultadoOperacion.crear_error(
        TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        {"motivo": motivo}
    )
