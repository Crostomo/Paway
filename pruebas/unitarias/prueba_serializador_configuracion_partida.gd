
extends RefCounted

const TipoConfiguracionPartida = preload("res://scripts/datos/modelos/configuracion_partida.gd")
const TipoSerializador = preload("res://scripts/datos/serializadores/serializador_configuracion_partida.gd")


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorConfiguracionPartida ---")

	var configuracion = TipoConfiguracionPartida.new()
	configuracion.id_partida = "prueba_001"
	configuracion.tipo_partida = TipoConfiguracionPartida.TIPO_NORMAL
	configuracion.filas = 5
	configuracion.columnas = 5
	configuracion.usar_cronometro = true
	configuracion.usar_pistas = false

	var resultado_serializacion = TipoSerializador.serializar(configuracion)

	if not resultado_serializacion.aceptado:
		print("Codigo de error: ", resultado_serializacion.codigo)
		print("Datos devueltos: ", resultado_serializacion.datos)
		push_error("Fallo al serializar la configuracion.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		resultado_serializacion.datos["datos"]
	)


	if not resultado_deserializacion.aceptado:
		push_error("Fallo al deserializar la configuracion.")
		return false

	var reconstruida = resultado_deserializacion.datos["configuracion"]

	if reconstruida.id_partida != configuracion.id_partida:
		push_error("El identificador no coincide.")
		return false

	if reconstruida.filas != configuracion.filas:
		push_error("El numero de filas no coincide.")
		return false

	if reconstruida.columnas != configuracion.columnas:
		push_error("El numero de columnas no coincide.")
		return false

	if reconstruida.usar_cronometro != configuracion.usar_cronometro:
		push_error("La configuracion del cronometro no coincide.")
		return false

	if reconstruida.usar_pistas != configuracion.usar_pistas:
		push_error("La configuracion de pistas no coincide.")
		return false

	print("RESULTADO: CORRECTO")
	return true
