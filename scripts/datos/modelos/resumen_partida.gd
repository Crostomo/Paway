
class_name ResumenPartida
extends RefCounted

const TipoConfiguracionPartida = preload(
    "res://scripts/datos/modelos/configuracion_partida.gd"
)

# Estados posibles de una partida.
const ESTADO_PREPARADA: String = "preparada"
const ESTADO_ACTIVA: String = "activa"
const ESTADO_PAUSADA: String = "pausada"
const ESTADO_BLOQUEADA: String = "bloqueada"
const ESTADO_COMPLETADA: String = "completada"
const ESTADO_ABANDONADA: String = "abandonada"

# Identificador de la partida.
var id_partida: String = ""

# Tipo de partida.
var tipo_partida: String = TipoConfiguracionPartida.TIPO_NORMAL

# Estado actual de la partida.
var estado: String = ESTADO_PREPARADA

# Tiempo acumulado de juego, expresado en segundos.
var tiempo_segundos: float = 0.0

# Indica si el cronometro esta habilitado.
var usar_cronometro: bool = true

# Numero de pistas utilizadas.
var pistas_utilizadas: int = 0

# Indica si el resultado final se ha registrado.
var resultado_registrado: bool = false

# Identificador del reto, si corresponde.
var id_reto: String = ""
