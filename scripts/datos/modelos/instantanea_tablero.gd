
class_name InstantaneaTablero
extends RefCounted

# Referencia al modelo de movimiento.
const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)

# Version del formato de la instantanea.
const VERSION_FORMATO: int = 1

var version_formato: int = VERSION_FORMATO

# Dimensiones del tablero.
var filas: int = 0
var columnas: int = 0

# Matriz completa del tablero.
# 0 representa una casilla vacia.
var matriz: Array[Array] = []

# Historial ordenado de movimientos.
var historial: Array[TipoRegistroMovimiento] = []

# Ultima casilla ocupada.
# Vector2i.x = columna; Vector2i.y = fila.
var ultima_casilla: Vector2i = Vector2i(-1, -1)

# Estado del tablero.
var estado: String = "preparada"

# Contadores de movimientos.
var movimientos_realizados: int = 0
var movimientos_deshechos: int = 0
var movimientos_efectivos: int = 0
