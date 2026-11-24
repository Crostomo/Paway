
class_name ReglasMovimiento
extends RefCounted

# Identidad del perfil de movimiento.
const ID_REGLAS_RECTANGULAR: String = "rectangular_saltos_3_2"
const VERSION_REGLAS_RECTANGULAR: int = 1

# Desplazamientos permitidos.
const DESPLAZAMIENTOS: Array[Vector2i] = [
	Vector2i(-3, 0),
	Vector2i(3, 0),
	Vector2i(0, -3),
	Vector2i(0, 3),
	Vector2i(-2, -2),
	Vector2i(-2, 2),
	Vector2i(2, -2),
	Vector2i(2, 2)
]

var id_reglas: String = ID_REGLAS_RECTANGULAR
var version_reglas: int = VERSION_REGLAS_RECTANGULAR


# Obtiene los identificadores de las casillas alcanzables.
# El identificador de destino se calcula mediante la geometria.
func obtener_destinos_validos(
	geometria: RefCounted,
	id_origen: int
) -> Array[int]:

	var destinos: Array[int] = []

	var coordenada_origen: Vector2i = (
		geometria.obtener_coordenadas_casilla(id_origen)
	)

	# Comprueba que la casilla de origen existe.
	if coordenada_origen == Vector2i(-1, -1):
		return destinos

	# Calcula los ocho posibles desplazamientos.
	for desplazamiento: Vector2i in DESPLAZAMIENTOS:

		var coordenada_destino: Vector2i = (
			coordenada_origen + desplazamiento
		)

		if not geometria.contiene_coordenada(coordenada_destino):
			continue

		var id_destino: int = (
			geometria.obtener_id_casilla(coordenada_destino)
		)

		if id_destino >= 0:
			destinos.append(id_destino)

	return destinos


# Comprueba si un destino pertenece a los movimientos permitidos.
func es_movimiento_valido(
	geometria: RefCounted,
	id_origen: int,
	id_destino: int
) -> bool:

	if id_origen == id_destino:
		return false

	var destinos: Array[int] = obtener_destinos_validos(
		geometria,
		id_origen
	)

	return destinos.has(id_destino)
