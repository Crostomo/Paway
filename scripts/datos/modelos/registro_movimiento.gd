
class_name RegistroMovimiento
extends RefCounted

# Numero asignado a la casilla en este movimiento.
var numero: int = 0

# Identificadores logicos de las casillas.
# Los IDs se interpretan dentro de la geometria del tablero.
# -1 indica que no existe una casilla de origen.
var origen_id: int = -1
var destino_id: int = -1

# Indica si se trata del primer movimiento.
# En ese caso no existe una casilla de origen.
var es_primer_movimiento: bool = false
