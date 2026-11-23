
class_name ConfiguracionPartida
extends RefCounted

# Tipos de partida disponibles.
const TIPO_NORMAL: String = "normal"
const TIPO_PERSONALIZADA: String = "personalizada"
const TIPO_RETO: String = "reto"

# Identificador unico de la partida.
var id_partida: String = ""

# Tipo de partida.
var tipo_partida: String = TIPO_NORMAL

# Dimensiones del tablero.
var filas: int = 0
var columnas: int = 0

# Casillas permitidas para comenzar.
# Cada Vector2i utiliza x = columna e y = fila.
# Una lista vacia significa que cualquier casilla esta permitida.
var inicio_permitido: Array[Vector2i] = []

# Casillas permitidas para terminar.
# Una lista vacia significa que cualquier casilla esta permitida.
var final_permitido: Array[Vector2i] = []

# Identificador del reto, si corresponde.
# Una cadena vacia indica que no hay reto asociado.
var id_reto: String = ""

# Opciones de la partida.
var usar_cronometro: bool = true
var usar_pistas: bool = false
