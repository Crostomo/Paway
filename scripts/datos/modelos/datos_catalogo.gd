
class_name DatosCatalogo
extends RefCounted

# Referencia directa al modelo de resultados del analisis.
const TipoResultadoAnalisis = preload(
    "res://scripts/datos/modelos/resultado_analisis.gd"
)

# Version de las reglas del juego.
var version_reglas: int = 1

# Identidad del tablero.
var id_tablero: String = ""
var filas: int = 0
var columnas: int = 0

# Estado de certificacion.
var certificacion: String = TipoResultadoAnalisis.CERTIFICACION_PENDIENTE

# Informacion sobre cobertura de casillas iniciales.
var cobertura_completa: bool = false
var inicios_comprobados: int = 0
var total_inicios: int = 0

# Informacion sobre el recuento de soluciones.
var tipo_recuento: String = TipoResultadoAnalisis.RECUENTO_NO_DETERMINADO
var soluciones_minimas: int = 0
var soluciones_maximas: int = 0
var recuento_exacto: int = -1

# Recorridos de referencia.
var recorridos_referencia: Array[Array] = []

# Informacion del proceso de preparacion.
var tiempo_analisis_segundos: float = 0.0
var nodos_explorados: int = 0
var version_algoritmo: String = ""

# Informacion de integridad.
var validacion_independiente_superada: bool = false
var identificador_integridad: String = ""
