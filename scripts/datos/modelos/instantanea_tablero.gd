
class_name InstantaneaTablero
extends RefCounted

# Referencia al modelo de movimiento.
const TipoRegistroMovimiento = preload(
	"res://scripts/datos/modelos/registro_movimiento.gd"
)

# Nueva version del formato.
const VERSION_FORMATO: int = 2

var version_formato: int = VERSION_FORMATO

# Identidad de geometria y reglas.
const GEOMETRIA_RECTANGULAR: String = "rectangular"
const VERSION_GEOMETRIA_RECTANGULAR: int = 1

const REGLAS_RECTANGULAR_SALTOS_3_2: String = (
	"rectangular_saltos_3_2"
)
const VERSION_REGLAS_RECTANGULAR_SALTOS_3_2: int = 1

var id_geometria: String = GEOMETRIA_RECTANGULAR
var version_geometria: int = VERSION_GEOMETRIA_RECTANGULAR

var id_reglas_movimiento: String = REGLAS_RECTANGULAR_SALTOS_3_2
var version_reglas_movimiento: int = VERSION_REGLAS_RECTANGULAR_SALTOS_3_2

# Dimensiones de la representacion rectangular.
var filas: int = 0
var columnas: int = 0

# Matriz completa del tablero.
# 0 representa una casilla vacia.
var matriz: Array[Array] = []

# Historial ordenado de movimientos.
var historial: Array[TipoRegistroMovimiento] = []

# Identificador logico de la ultima casilla ocupada.
# -1 indica que no existe ninguna.
var ultima_casilla_id: int = -1

# Estado del tablero.
var estado: String = "preparada"

# Contadores de movimientos.
var movimientos_realizados: int = 0
var movimientos_deshechos: int = 0
var movimientos_efectivos: int = 0
