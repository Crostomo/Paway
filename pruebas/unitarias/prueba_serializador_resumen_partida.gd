
extends RefCounted

const TipoResumenPartida = preload(
    "res://scripts/datos/modelos/resumen_partida.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_resumen_partida.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorResumenPartida ---")

	var resumen = TipoResumenPartida.new()

	resumen.id_partida = "partida_prueba_001"
	resumen.tipo_partida = "normal"
	resumen.estado = TipoResumenPartida.ESTADO_ACTIVA
	resumen.tiempo_segundos = 125.75
	resumen.usar_cronometro = true
	resumen.pistas_utilizadas = 2
	resumen.resultado_registrado = false
	resumen.id_reto = ""

	# Serializacion.
	var resultado_serializacion = TipoSerializador.serializar(
		resumen
	)

	if resultado_serializacion == null:
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error: ", resultado_serializacion.datos)
		push_error("No se ha podido serializar el resumen.")
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
		push_error("No se ha podido deserializar el resumen.")
		return false

	var reconstruido = resultado_deserializacion.datos["resumen"]

	# Comprobar todos los campos.
	if reconstruido.id_partida != resumen.id_partida:
		push_error("El identificador de partida no coincide.")
		return false

	if reconstruido.tipo_partida != resumen.tipo_partida:
		push_error("El tipo de partida no coincide.")
		return false

	if reconstruido.estado != resumen.estado:
		push_error("El estado de partida no coincide.")
		return false

	if reconstruido.tiempo_segundos != resumen.tiempo_segundos:
		push_error("El tiempo no coincide.")
		return false

	if reconstruido.usar_cronometro != resumen.usar_cronometro:
		push_error("La configuracion del cronometro no coincide.")
		return false

	if reconstruido.pistas_utilizadas != resumen.pistas_utilizadas:
		push_error("El contador de pistas no coincide.")
		return false

	if reconstruido.resultado_registrado != resumen.resultado_registrado:
		push_error("El estado del registro no coincide.")
		return false

	if reconstruido.id_reto != resumen.id_reto:
		push_error("El identificador del reto no coincide.")
		return false

	# Caso incorrecto 1: partida de reto sin identificador.
	var resumen_reto = TipoResumenPartida.new()
	resumen_reto.id_partida = "partida_reto_invalida"
	resumen_reto.tipo_partida = "reto"
	resumen_reto.id_reto = ""

	if TipoSerializador.serializar(resumen_reto).aceptado:
		push_error("Se ha aceptado un reto sin identificador.")
		return false

	# Caso incorrecto 2: identificador de reto con espacios.
	resumen_reto.id_reto = "   "

	if TipoSerializador.serializar(resumen_reto).aceptado:
		push_error("Se ha aceptado un identificador de reto vacio.")
		return false

	# Caso incorrecto 3: resultado registrado en partida activa.
	var resumen_incoherente = TipoResumenPartida.new()
	resumen_incoherente.id_partida = "partida_incoherente"
	resumen_incoherente.estado = TipoResumenPartida.ESTADO_ACTIVA
	resumen_incoherente.resultado_registrado = true

	if TipoSerializador.serializar(resumen_incoherente).aceptado:
		push_error("Se ha aceptado un resultado registrado en partida activa.")
		return false

	# Caso incorrecto 4: tiempo negativo.
	var datos_tiempo_invalido: Dictionary = (
		datos_serializados.duplicate(true)
	)
	datos_tiempo_invalido["tiempo_segundos"] = -10.0

	if TipoSerializador.deserializar(datos_tiempo_invalido).aceptado:
		push_error("Se ha aceptado un tiempo negativo.")
		return false

	print("RESULTADO: CORRECTO")
	return true
