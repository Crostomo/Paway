
class_name EstadoTablero
extends RefCounted

# Referencia directa al modelo de movimiento.
const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)

# Estados posibles del tablero.
const ESTADO_PREPARADA: String = "preparada"
const ESTADO_ACTIVA: String = "activa"
const ESTADO_BLOQUEADA: String = "bloqueada"
const ESTADO_COMPLETADA: String = "completada"

# Dimensiones.
var filas: int = 0
var columnas: int = 0

# Matriz del tablero.
# 0 representa una casilla vacia.
# Los demas valores representan numeros asignados.
var matriz: Array[Array] = []

# Historial ordenado de movimientos.
var historial: Array[TipoRegistroMovimiento] = []

# Ultima casilla ocupada.
# Vector2i.x = columna; Vector2i.y = fila.
var ultima_casilla: Vector2i = Vector2i(-1, -1)

# Estado actual del tablero.
var estado: String = ESTADO_PREPARADA

# Contadores de movimientos.
var movimientos_realizados: int = 0
var movimientos_deshechos: int = 0
var movimientos_efectivos: int = 0
