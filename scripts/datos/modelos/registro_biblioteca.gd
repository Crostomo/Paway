
class_name RegistroBiblioteca
extends RefCounted

# Version del formato del registro.
var version_formato: int = 2

# Identidad de la geometria y las reglas.
var id_geometria: String = "rectangular"
var version_geometria: int = 1
var id_reglas_movimiento: String = "rectangular_saltos_3_2"
var version_reglas_movimiento: int = 1

# Identificacion del recorrido.
var id_recorrido: String = ""
var tipo_partida: String = "normal"
var id_reto: String = ""

# Dimensiones del tablero.
var filas: int = 0
var columnas: int = 0

# Recorrido completado mediante identificadores estables de casilla.
var recorrido: Array[int] = []

# Datos de la partida.
var fecha_completado: String = ""
var tiempo_segundos: float = 0.0
var movimientos_realizados: int = 0
var movimientos_deshechados: int = 0
var movimientos_efectivos: int = 0
var pistas_utilizadas: int = 0

# Preferencias de biblioteca.
var favorito: bool = false
