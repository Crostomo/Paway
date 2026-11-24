
class_name ConfiguracionPartida
extends RefCounted

# Tipos de partida disponibles.
const TIPO_NORMAL: String = "normal"
const TIPO_PERSONALIZADA: String = "personalizada"
const TIPO_RETO: String = "reto"

# Geometrias disponibles.
const GEOMETRIA_RECTANGULAR: String = "rectangular"
const VERSION_GEOMETRIA_RECTANGULAR: int = 1

# Perfiles de reglas de movimiento.
const REGLAS_RECTANGULAR_SALTOS_3_2: String = "rectangular_saltos_3_2"
const VERSION_REGLAS_RECTANGULAR_SALTOS_3_2: int = 1

# Identificador unico de la partida.
var id_partida: String = ""

# Tipo de partida.
var tipo_partida: String = TIPO_NORMAL

# Identificacion de la geometria.
var id_geometria: String = GEOMETRIA_RECTANGULAR
var version_geometria: int = VERSION_GEOMETRIA_RECTANGULAR

# Identificacion de las reglas de movimiento.
var id_reglas_movimiento: String = REGLAS_RECTANGULAR_SALTOS_3_2
var version_reglas_movimiento: int = VERSION_REGLAS_RECTANGULAR_SALTOS_3_2

# Dimensiones del tablero rectangular.
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
