
extends RefCounted

const TipoDatosCatalogo = preload(
    "res://scripts/datos/modelos/datos_catalogo.gd"
)
const TipoResultadoAnalisis = preload(
    "res://scripts/datos/modelos/resultado_analisis.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_datos_catalogo.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorDatosCatalogo ---")

	var catalogo = TipoDatosCatalogo.new()

	catalogo.version_reglas = 1
	catalogo.id_tablero = "tablero_5x5"
	catalogo.filas = 5
	catalogo.columnas = 5

	catalogo.certificacion = (
		TipoResultadoAnalisis.CERTIFICACION_COBERTURA_COMPLETA
	)

	catalogo.cobertura_completa = true
	catalogo.inicios_comprobados = 25
	catalogo.total_inicios = 25

	catalogo.tipo_recuento = (
		TipoResultadoAnalisis.RECUENTO_NO_DETERMINADO
	)
	catalogo.soluciones_minimas = 0
	catalogo.soluciones_maximas = 0
	catalogo.recuento_exacto = -1

	# Recorrido completo valido de 5x5.
	var recorrido: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(3, 0),
		Vector2i(3, 3),
		Vector2i(0, 3),
		Vector2i(2, 1),
		Vector2i(2, 4),
		Vector2i(4, 2),
		Vector2i(1, 2),
		Vector2i(3, 4),
		Vector2i(0, 4),
		Vector2i(0, 1),
		Vector2i(3, 1),
		Vector2i(1, 3),
		Vector2i(4, 3),
		Vector2i(4, 0),
		Vector2i(1, 0),
		Vector2i(3, 2),
		Vector2i(0, 2),
		Vector2i(2, 0),
		Vector2i(2, 3),
		Vector2i(4, 1),
		Vector2i(1, 1),
		Vector2i(1, 4),
		Vector2i(4, 4),
		Vector2i(2, 2)
	]

	catalogo.recorridos_referencia.append(recorrido)

	catalogo.tiempo_analisis_segundos = 15.5
	catalogo.nodos_explorados = 25000
	catalogo.version_algoritmo = "1.0"
	catalogo.validacion_independiente_superada = true
	catalogo.identificador_integridad = "integridad_prueba_001"

	# Serializacion.
	var resultado_serializacion = TipoSerializador.serializar(
		catalogo
	)

	if resultado_serializacion == null:
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error: ", resultado_serializacion.datos)
		push_error("No se ha podido serializar el catalogo.")
		return false

	var datos_serializados: Dictionary = (
		resultado_serializacion.datos["datos"]
	)

	# Deserializacion.
	var resultado_deserializacion = TipoSerializador.deserializar(
		datos_serializados
	)

	if resultado_deserializacion == null:
		push_error("La deserializacion ha devuelto null.")
		return false

	if not resultado_deserializacion.aceptado:
		print("Error: ", resultado_deserializacion.datos)
		push_error("No se ha podido deserializar el catalogo.")
		return false

	var reconstruido = resultado_deserializacion.datos["catalogo"]

	# Comprobar dimensiones e identidad.
	if reconstruido.id_tablero != catalogo.id_tablero:
		push_error("El identificador del tablero no coincide.")
		return false

	if reconstruido.filas != 5 or reconstruido.columnas != 5:
		push_error("Las dimensiones no coinciden.")
		return false

	# Comprobar certificacion y cobertura.
	if not reconstruido.cobertura_completa:
		push_error("Se ha perdido la cobertura completa.")
		return false

	if reconstruido.inicios_comprobados != 25:
		push_error("El numero de inicios comprobados no coincide.")
		return false

	if reconstruido.certificacion != catalogo.certificacion:
		push_error("La certificacion no coincide.")
		return false

	# Comprobar recorrido.
	if reconstruido.recorridos_referencia.size() != 1:
		push_error("El numero de recorridos no coincide.")
		return false

	var recorrido_reconstruido: Array = (
		reconstruido.recorridos_referencia[0]
	)

	if recorrido_reconstruido.size() != 25:
		push_error("El recorrido no contiene las 25 casillas.")
		return false

	for indice in range(25):
		if recorrido_reconstruido[indice] != recorrido[indice]:
			push_error("No coincide la posicion del recorrido: " + str(indice))
			return false

	# Caso incorrecto 1: certificacion incompatible con la cobertura.
	var catalogo_incoherente = TipoDatosCatalogo.new()
	catalogo_incoherente.version_reglas = catalogo.version_reglas
	catalogo_incoherente.id_tablero = catalogo.id_tablero
	catalogo_incoherente.filas = catalogo.filas
	catalogo_incoherente.columnas = catalogo.columnas
	catalogo_incoherente.certificacion = (
		TipoResultadoAnalisis.CERTIFICACION_SOLVENCIA
	)
	catalogo_incoherente.cobertura_completa = true
	catalogo_incoherente.inicios_comprobados = 25
	catalogo_incoherente.total_inicios = 25

	if TipoSerializador.serializar(catalogo_incoherente).aceptado:
		push_error("Se ha aceptado una certificacion incompatible.")
		return false

	# Caso incorrecto 2: recorrido con movimiento ilegal.
	var datos_movimiento_invalido: Dictionary = (
		datos_serializados.duplicate(true)
	)

	datos_movimiento_invalido["recorridos_referencia"][0][1]["x"] = 1

	var resultado_movimiento_invalido = (
		TipoSerializador.deserializar(datos_movimiento_invalido)
	)

	if resultado_movimiento_invalido.aceptado:
		push_error("Se ha aceptado un movimiento ilegal.")
		return false

	# Caso incorrecto 3: recorrido con una casilla repetida.
	var datos_casilla_repetida: Dictionary = (
		datos_serializados.duplicate(true)
	)

	datos_casilla_repetida["recorridos_referencia"][0][1] = {
		"x": 0,
		"y": 0
	}

	var resultado_casilla_repetida = (
		TipoSerializador.deserializar(datos_casilla_repetida)
	)

	if resultado_casilla_repetida.aceptado:
		push_error("Se ha aceptado una casilla repetida.")
		return false

	print("RESULTADO: CORRECTO")
	return true
