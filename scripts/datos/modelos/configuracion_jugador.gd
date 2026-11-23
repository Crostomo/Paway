
class_name ConfiguracionJugador
extends RefCounted

# Version del formato de configuracion.
var version_formato: int = 1

# Apariencia.
var tema: String = "sistema"
var estilo_visual: String = "clasico"
var idioma: String = "automatico"
var tipografia: String = "predeterminada"
var escala_texto: float = 1.0
var contraste_alto: bool = false

# Tablero.
var mostrar_movimientos_validos: bool = false
var mostrar_casillas_utilizadas: bool = true
var tamano_numeros: float = 1.0

# Accesibilidad y movimiento.
var reducir_animaciones: bool = false
var usar_vibracion: bool = true
var usar_sonidos: bool = true
var usar_lector_pantalla: bool = true

# Opciones de partida.
var usar_cronometro_por_defecto: bool = true
var usar_pistas_por_defecto: bool = false
var confirmar_abandono: bool = true
var confirmar_reinicio: bool = true

# Fecha de la ultima actualizacion.
var ultima_actualizacion: String = ""
