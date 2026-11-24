
extends RefCounted

const TipoResultadoAnalisis = preload(
    "res://scripts/datos/modelos/resultado_analisis.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_resultado_analisis.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorResultadoAnalisis ---")

	var analisis = TipoResultadoAnalisis.new()

	analisis.id_tablero = "tablero_5x5"
	analisis.id_problema = "problema_5x5_libre"

	analisis.certificacion = (
		TipoResultadoAnalisis.CERTIFICACION_SOLVENCIA
	)

	analisis.tipo_recuento = (
		TipoResultadoAnalisis.RECUENTO_EXACTO
	)

	analisis.soluciones_minimas = 3
	analisis.soluciones_maximas = 3
	analisis.recuento_exacto = 3

	analisis.recorrido_referencia.append(Vector2i(0, 0))
	analisis.recorrido_referencia.append(Vector2i(3, 0))
	analisis.recorrido_referencia.append(Vector2i(3, 3))
	analisis.recorrido_referencia.append(Vector2i(0, 3))

	analisis.analisis_completo = true
	analisis.tiempo_segundos = 12.75
	analisis.nodos_explorados = 15420
	analisis.version_algoritmo = "1.0"
	analisis.validacion_independiente_superada = true

	# Serializacion.
	var resultado_serializacion = TipoSerializador.serializar(
		analisis
	)

	if resultado_serializacion == null:
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error: ", resultado_serializacion.datos)
		push_error("Fallo al serializar el analisis.")
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
		push_error("Fallo al deserializar el analisis.")
		return false

	var reconstruido = resultado_deserializacion.datos["analisis"]

	# Comprobacion de identificadores.
	if reconstruido.id_tablero != analisis.id_tablero:
		push_error("El identificador del tablero no coincide.")
		return false

	if reconstruido.id_problema != analisis.id_problema:
		push_error("El identificador del problema no coincide.")
		return false

	# Comprobacion de certificacion y recuento.
	if reconstruido.certificacion != analisis.certificacion:
		push_error("La certificacion no coincide.")
		return false

	if reconstruido.tipo_recuento != analisis.tipo_recuento:
		push_error("El tipo de recuento no coincide.")
		return false

	if reconstruido.soluciones_minimas != analisis.soluciones_minimas:
		push_error("Las soluciones minimas no coinciden.")
		return false

	if reconstruido.soluciones_maximas != analisis.soluciones_maximas:
		push_error("Las soluciones maximas no coinciden.")
		return false

	if reconstruido.recuento_exacto != analisis.recuento_exacto:
		push_error("El recuento exacto no coincide.")
		return false

	# Comprobacion del recorrido.
	if reconstruido.recorrido_referencia.size() != analisis.recorrido_referencia.size():
		push_error("El numero de posiciones del recorrido no coincide.")
		return false

	for indice in range(analisis.recorrido_referencia.size()):
		if reconstruido.recorrido_referencia[indice] != analisis.recorrido_referencia[indice]:
			push_error("No coincide la posicion del recorrido: " + str(indice))
			return false

	# Comprobacion de datos de ejecucion.
	if reconstruido.analisis_completo != analisis.analisis_completo:
		push_error("El estado del analisis no coincide.")
		return false

	if reconstruido.tiempo_segundos != analisis.tiempo_segundos:
		push_error("El tiempo del analisis no coincide.")
		return false

	if reconstruido.nodos_explorados != analisis.nodos_explorados:
		push_error("Los nodos explorados no coinciden.")
		return false

	if reconstruido.version_algoritmo != analisis.version_algoritmo:
		push_error("La version del algoritmo no coincide.")
		return false

	if reconstruido.validacion_independiente_superada != analisis.validacion_independiente_superada:
		push_error("La validacion independiente no coincide.")
		return false

	# Comprobacion de rechazo de un recuento incoherente.
	var datos_invalidos: Dictionary = datos_serializados.duplicate(true)
	datos_invalidos["soluciones_maximas"] = 5

	var resultado_invalido = TipoSerializador.deserializar(
		datos_invalidos
	)

	if resultado_invalido.aceptado:
		push_error("Se ha aceptado un recuento exacto incoherente.")
		return false

	print("RESULTADO: CORRECTO")
	return true
