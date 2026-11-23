
class_name DatosProgreso
extends RefCounted

# Version del formato de progreso.
var version_formato: int = 1

# Experiencia total acumulada.
var experiencia_total: int = 0

# Nivel actual del jugador.
var nivel_actual: int = 1

# Identificadores de tableros y retos cuya recompensa
# de experiencia ya se ha concedido.
var recompensas_concedidas: Array[String] = []

# Dimensiones de tablero que el jugador ha completado.
# Cada elemento utiliza el formato "filasxcolumnas".
var dimensiones_completadas: Array[String] = []

# Fecha de la ultima actualizacion.
var ultima_actualizacion: String = ""
