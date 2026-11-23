
class_name ResultadoOperacion
extends RefCounted

# Códigos de resultado.
const CODIGO_CORRECTO: String = "CORRECTO"
const CODIGO_MOVIMIENTO_NO_PERMITIDO: String = "MOVIMIENTO_NO_PERMITIDO"
const CODIGO_CASILLA_OCUPADA: String = "CASILLA_OCUPADA"
const CODIGO_FUERA_TABLERO: String = "FUERA_TABLERO"
const CODIGO_TABLERO_NO_PREPARADO: String = "TABLERO_NO_PREPARADO"
const CODIGO_PARTIDA_NO_ACTIVA: String = "PARTIDA_NO_ACTIVA"
const CODIGO_SIN_MOVIMIENTOS: String = "SIN_MOVIMIENTOS"
const CODIGO_DATOS_INVALIDOS: String = "DATOS_INVALIDOS"

# Indica si la operacion ha sido aceptada.
var aceptado: bool = false

# Codigo que identifica el resultado.
var codigo: String = CODIGO_DATOS_INVALIDOS

# Datos adicionales del resultado.
var datos: Dictionary = {}

# Crea un resultado aceptado.
static func crear_correcto(
    nuevo_codigo: String,
    nuevos_datos: Dictionary = {}
) -> ResultadoOperacion:
    var resultado := ResultadoOperacion.new()
    resultado.aceptado = true
    resultado.codigo = nuevo_codigo
    resultado.datos = nuevos_datos.duplicate(true)
    return resultado

# Crea un resultado rechazado.
static func crear_error(
    nuevo_codigo: String,
    nuevos_datos: Dictionary = {}
) -> ResultadoOperacion:
    var resultado := ResultadoOperacion.new()
    resultado.aceptado = false
    resultado.codigo = nuevo_codigo
    resultado.datos = nuevos_datos.duplicate(true)
    return resultado
