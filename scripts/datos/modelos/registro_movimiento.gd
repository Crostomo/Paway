
class_name RegistroMovimiento
extends RefCounted

# Numero asignado a la casilla en este movimiento.
var numero: int = 0

# Coordenadas de origen y destino.
# Vector2i.x representa la columna.
# Vector2i.y representa la fila.
var origen: Vector2i = Vector2i(-1, -1)
var destino: Vector2i = Vector2i(-1, -1)

# Indica si se trata del primer movimiento.
# En ese caso no existe una casilla de origen.
var es_primer_movimiento: bool = false
