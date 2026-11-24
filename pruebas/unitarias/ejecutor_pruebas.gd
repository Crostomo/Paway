
extends SceneTree

const PruebaConfiguracionPartida = preload(
    "res://pruebas/unitarias/prueba_serializador_configuracion_partida.gd"
)
const PruebaRegistroMovimiento = preload(
    "res://pruebas/unitarias/prueba_serializador_registro_movimiento.gd"
)
const PruebaEstadoTablero = preload(
    "res://pruebas/unitarias/prueba_serializador_estado_tablero.gd"
)
const PruebaInstantaneaTablero = preload(
    "res://pruebas/unitarias/prueba_serializador_instantanea_tablero.gd"
)
const PruebaDatosProgreso = preload(
    "res://pruebas/unitarias/prueba_serializador_datos_progreso.gd"
)
const PruebaConfiguracionJugador = preload(
    "res://pruebas/unitarias/prueba_serializador_configuracion_jugador.gd"
)
const PruebaRegistroEstadisticas = preload(
    "res://pruebas/unitarias/prueba_serializador_registro_estadisticas.gd"
)
const PruebaRegistroBiblioteca = preload(
    "res://pruebas/unitarias/prueba_serializador_registro_biblioteca.gd"
)
const PruebaResultadoAnalisis = preload(
    "res://pruebas/unitarias/prueba_serializador_resultado_analisis.gd"
)
const PruebaDatosCatalogo = preload(
    "res://pruebas/unitarias/prueba_serializador_datos_catalogo.gd"
)
const PruebaResumenPartida = preload(
    "res://pruebas/unitarias/prueba_serializador_resumen_partida.gd"
)

const PruebaValidadorDimensiones = preload(
    "res://pruebas/unitarias/prueba_validador_dimensiones_tablero.gd"
)

const PruebaValidadorConfiguracion = preload(
    "res://pruebas/unitarias/prueba_validador_configuracion_partida.gd"
)

const PruebaValidadorEstado = preload(
	"res://pruebas/unitarias/prueba_validador_estado_tablero.gd"
)

const PruebaValidadorInstantanea = preload(
	"res://pruebas/unitarias/prueba_validador_instantanea_tablero.gd"
)

const PruebaValidadorDatosProgreso = preload(
	"res://pruebas/unitarias/prueba_validador_datos_progreso.gd"
)

const PruebaValidadorConfiguracionJugador = preload(
	"res://pruebas/unitarias/prueba_validador_configuracion_jugador.gd"
)


const PruebaGeometriaTablero = preload(
	"res://pruebas/unitarias/prueba_geometria_tablero.gd"
)
const PruebaReglasMovimiento = preload(
	"res://pruebas/unitarias/prueba_reglas_movimiento.gd"
)


func _initialize() -> void:
	call_deferred("_ejecutar_pruebas")

func _ejecutar_pruebas() -> void:
	print("")
	print("====================================")
	print("       PRUEBAS UNITARIAS PAWAY")
	print("====================================")

	var total_pruebas: int = 19
	var pruebas_correctas: int = 0

	if PruebaConfiguracionPartida.ejecutar():
		pruebas_correctas += 1

	if PruebaRegistroMovimiento.ejecutar():
		pruebas_correctas += 1

	if PruebaEstadoTablero.ejecutar():
		pruebas_correctas += 1

	if PruebaInstantaneaTablero.ejecutar():
		pruebas_correctas += 1

	if PruebaDatosProgreso.ejecutar():
		pruebas_correctas += 1

	if PruebaConfiguracionJugador.ejecutar():
		pruebas_correctas += 1

	if PruebaRegistroEstadisticas.ejecutar():
		pruebas_correctas += 1

	if PruebaRegistroBiblioteca.ejecutar():
		pruebas_correctas += 1

	if PruebaResultadoAnalisis.ejecutar():
		pruebas_correctas += 1

	if PruebaDatosCatalogo.ejecutar():
		pruebas_correctas += 1

	if PruebaResumenPartida.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorDimensiones.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorConfiguracion.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorEstado.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorInstantanea.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorDatosProgreso.ejecutar():
		pruebas_correctas += 1

	if PruebaValidadorConfiguracionJugador.ejecutar():
		pruebas_correctas += 1

	if PruebaGeometriaTablero.ejecutar():
		pruebas_correctas += 1

	if PruebaReglasMovimiento.ejecutar():
		pruebas_correctas += 1

	print("")
	print("====================================")
	print("           RESUMEN")
	print("====================================")
	print("Pruebas ejecutadas: ", total_pruebas)
	print("Pruebas correctas: ", pruebas_correctas)
	print("Pruebas fallidas: ", total_pruebas - pruebas_correctas)

	if pruebas_correctas == total_pruebas:
		print("RESULTADO GENERAL: CORRECTO")
		quit(0)
	else:
		print("RESULTADO GENERAL: ERROR")
		quit(1)
