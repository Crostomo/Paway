
class_name EstadoTablero
extends RefCounted

# Referencia directa al modelo de movimiento.
const TipoRegistroMovimiento = preload(
	"res://scripts/datos/modelos/registro_movimiento.gd"
)

# Identidad de la geometria y las reglas.
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

# Matriz del tablero.
# 0 representa una casilla vacia.
# Los demas valores representan numeros asignados.
var matriz: Array[Array] = []

# Historial ordenado de movimientos.
var historial: Array[TipoRegistroMovimiento] = []

# Identificador logico de la ultima casilla ocupada.
# -1 indica que todavia no hay ninguna casilla ocupada.
var ultima_casilla_id: int = -1

# Estado actual del tablero.
const ESTADO_PREPARADA: String = "preparada"
const ESTADO_ACTIVA: String = "activa"
const ESTADO_BLOQUEADA: String = "bloqueada"
const ESTADO_COMPLETADA: String = "completada"

var estado: String = ESTADO_PREPARADA

# Contadores de movimientos.
var movimientos_realizados: int = 0
var movimientos_deshechos: int = 0
var movimientos_efectivos: int = 0
