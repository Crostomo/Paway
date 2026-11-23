
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


func _initialize() -> void:
    call_deferred("_ejecutar_pruebas")


func _ejecutar_pruebas() -> void:
    print("")
    print("====================================")
    print("       PRUEBAS UNITARIAS PAWAY")
    print("====================================")

    var total_pruebas: int = 4
    var pruebas_correctas: int = 0

    if PruebaConfiguracionPartida.ejecutar():
        pruebas_correctas += 1

    if PruebaRegistroMovimiento.ejecutar():
        pruebas_correctas += 1

    if PruebaEstadoTablero.ejecutar():
        pruebas_correctas += 1

    if PruebaInstantaneaTablero.ejecutar():
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
