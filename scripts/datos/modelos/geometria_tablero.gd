
class_name GeometriaTablero
extends RefCounted

# Identificadores de geometria disponibles.
const GEOMETRIA_RECTANGULAR: String = "rectangular"
const VERSION_RECTANGULAR: int = 1

# Identidad de la geometria.
var id_geometria: String = GEOMETRIA_RECTANGULAR
var version_geometria: int = VERSION_RECTANGULAR

# Dimensiones de la geometria rectangular.
var filas: int = 0
var columnas: int = 0


# Configura una geometria rectangular.
func configurar_rectangular(
	nuevas_filas: int,
	nuevas_columnas: int
) -> bool:

	if nuevas_filas < 1 or nuevas_columnas < 1:
		return false

	id_geometria = GEOMETRIA_RECTANGULAR
	version_geometria = VERSION_RECTANGULAR
	filas = nuevas_filas
	columnas = nuevas_columnas

	return true


# Devuelve el numero total de casillas.
func obtener_total_casillas() -> int:
	return filas * columnas


# Comprueba si unas coordenadas pertenecen al tablero.
# Vector2i.x = columna.
# Vector2i.y = fila.
func contiene_coordenada(coordenada: Vector2i) -> bool:

	return (
		coordenada.x >= 0
		and coordenada.x < columnas
		and coordenada.y >= 0
		and coordenada.y < filas
	)


# Convierte unas coordenadas en un identificador de casilla.
# Devuelve -1 si las coordenadas no son validas.
func obtener_id_casilla(coordenada: Vector2i) -> int:

	if not contiene_coordenada(coordenada):
		return -1

	return coordenada.y * columnas + coordenada.x


# Comprueba si existe una casilla con ese identificador.
func contiene_id_casilla(id_casilla: int) -> bool:

	return (
		id_casilla >= 0
		and id_casilla < obtener_total_casillas()
	)


# Convierte un identificador en coordenadas.
# Devuelve (-1, -1) si el identificador no es valido.
func obtener_coordenadas_casilla(
	id_casilla: int
) -> Vector2i:

	if not contiene_id_casilla(id_casilla):
		return Vector2i(-1, -1)

	var fila: int = id_casilla / columnas
	var columna: int = id_casilla % columnas

	return Vector2i(columna, fila)
