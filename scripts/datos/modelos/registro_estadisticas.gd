
class_name RegistroEstadisticas
extends RefCounted

# Version del formato de estadisticas.
var version_formato: int = 1

# Partidas e intentos.
var partidas_completadas: int = 0
var intentos_no_completados: int = 0

# Movimientos acumulados.
var movimientos_realizados: int = 0
var movimientos_deshechados: int = 0
var movimientos_efectivos: int = 0

# Tiempo acumulado de juego, en segundos.
var tiempo_total_segundos: float = 0.0

# Mayor numero de casillas alcanzado en una partida no completada.
var mayor_tablero_no_completado: int = 0

# Numero total de pistas utilizadas.
var pistas_utilizadas: int = 0

# Mejores tiempos por dimensiones del tablero.
# Clave: "filasxcolumnas".
# Valor: tiempo en segundos.
var mejores_tiempos: Dictionary = {}

# Resumenes de partidas para el historial estadistico.
var historial_partidas: Array[Dictionary] = []

# Fecha de la ultima actualizacion.
var ultima_actualizacion: String = ""
