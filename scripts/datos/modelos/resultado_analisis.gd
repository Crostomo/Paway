
class_name ResultadoAnalisis
extends RefCounted

# Estados de certificacion del analisis.
const CERTIFICACION_PENDIENTE: String = "pendiente"
const CERTIFICACION_SOLVENCIA: String = "solvencia_demostrada"
const CERTIFICACION_COBERTURA_COMPLETA: String = "cobertura_completa"
const CERTIFICACION_IMPOSIBILIDAD: String = "imposibilidad_demostrada"
const CERTIFICACION_INCOMPLETA: String = "analisis_incompleto"

# Tipos de recuento de soluciones.
const RECUENTO_NO_DETERMINADO: String = "no_determinado"
const RECUENTO_EXACTO: String = "exacto"
const RECUENTO_BANDA: String = "banda"
const RECUENTO_LIMITE_INFERIOR: String = "limite_inferior"

# Identificacion del tablero y del problema.
var id_tablero: String = ""
var id_problema: String = ""

# Resultado de la certificacion.
var certificacion: String = CERTIFICACION_PENDIENTE

# Informacion sobre el recuento de soluciones.
var tipo_recuento: String = RECUENTO_NO_DETERMINADO
var soluciones_minimas: int = 0
var soluciones_maximas: int = 0
var recuento_exacto: int = -1

# Recorrido de referencia, si se ha encontrado.
# Cada elemento representa una coordenada Vector2i.
var recorrido_referencia: Array[Vector2i] = []

# Datos de ejecucion del analisis.
var analisis_completo: bool = false
var tiempo_segundos: float = 0.0
var nodos_explorados: int = 0

# Version del algoritmo que produjo el resultado.
var version_algoritmo: String = ""

# Indica si el recorrido ha superado la validacion independiente.
var validacion_independiente_superada: bool = false
