
extends RefCounted

const TipoInstantanea = preload(
    "res://scripts/datos/modelos/instantanea_tablero.gd"
)
const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_instantanea_tablero.gd"
)
const TipoEstadoTablero = preload(
    "res://scripts/datos/modelos/estado_tablero.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorInstantaneaTablero ---")

	var instantanea = TipoInstantanea.new()

	instantanea.version_formato = 1
	instantanea.filas = 5
	instantanea.columnas = 5

	instantanea.matriz.clear()

	for fila in range(instantanea.filas):
		var nueva_fila: Array[int] = []

		for columna in range(instantanea.columnas):
			nueva_fila.append(0)

		instantanea.matriz.append(nueva_fila)

	# Recorrido válido de tres movimientos.
	instantanea.matriz[2][3] = 1
	instantanea.matriz[2][0] = 2
	instantanea.matriz[4][2] = 3

	var primero = TipoRegistroMovimiento.new()
	primero.numero = 1
	primero.origen = Vector2i(-1, -1)
	primero.destino = Vector2i(3, 2)
	primero.es_primer_movimiento = true
	instantanea.historial.append(primero)

	var segundo = TipoRegistroMovimiento.new()
	segundo.numero = 2
	segundo.origen = Vector2i(3, 2)
	segundo.destino = Vector2i(0, 2)
	segundo.es_primer_movimiento = false
	instantanea.historial.append(segundo)

	var tercero = TipoRegistroMovimiento.new()
	tercero.numero = 3
	tercero.origen = Vector2i(0, 2)
	tercero.destino = Vector2i(2, 4)
	tercero.es_primer_movimiento = false
	instantanea.historial.append(tercero)

	instantanea.ultima_casilla = Vector2i(2, 4)
	instantanea.estado = TipoEstadoTablero.ESTADO_ACTIVA
	instantanea.movimientos_realizados = 3
	instantanea.movimientos_deshechos = 0
	instantanea.movimientos_efectivos = 3

	var resultado_serializacion = TipoSerializador.serializar(instantanea)
	
	if resultado_serializacion == null:
		push_error("SerializadorInstantaneaTablero.serializar() ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error de serializacion: ", resultado_serializacion.datos)
		push_error("Fallo al serializar la instantanea.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		resultado_serializacion.datos["datos"]
	)

	if resultado_deserializacion == null:
		push_error("SerializadorInstantaneaTablero.deserializar() ha devuelto null.")
		return false

	if not resultado_deserializacion.aceptado:
		print("Error de deserializacion: ", resultado_deserializacion.datos)
		push_error("Fallo al deserializar la instantanea.")
		return false

	var reconstruida = resultado_deserializacion.datos["instantanea"]

	if reconstruida.version_formato != instantanea.version_formato:
		push_error("La version del formato no coincide.")
		return false

	if reconstruida.filas != instantanea.filas:
		push_error("El numero de filas no coincide.")
		return false

	if reconstruida.columnas != instantanea.columnas:
		push_error("El numero de columnas no coincide.")
		return false

	if reconstruida.matriz != instantanea.matriz:
		push_error("La matriz no coincide.")
		return false

	if reconstruida.historial.size() != instantanea.historial.size():
		push_error("El historial no coincide.")
		return false

	if reconstruida.ultima_casilla != instantanea.ultima_casilla:
		push_error("La ultima casilla no coincide.")
		return false

	if reconstruida.estado != instantanea.estado:
		push_error("El estado no coincide.")
		return false

	if reconstruida.movimientos_realizados != instantanea.movimientos_realizados:
		push_error("El contador de movimientos realizados no coincide.")
		return false

	if reconstruida.movimientos_deshechos != instantanea.movimientos_deshechos:
		push_error("El contador de movimientos deshechos no coincide.")
		return false

	if reconstruida.movimientos_efectivos != instantanea.movimientos_efectivos:
		push_error("El contador de movimientos efectivos no coincide.")
		return false

	for indice in range(instantanea.historial.size()):
		var original = instantanea.historial[indice]
		var copia = reconstruida.historial[indice]

		if original.numero != copia.numero:
			push_error("La numeracion del historial no coincide.")
			return false

		if original.origen != copia.origen:
			push_error("El origen del historial no coincide.")
			return false

		if original.destino != copia.destino:
			push_error("El destino del historial no coincide.")
			return false

		if original.es_primer_movimiento != copia.es_primer_movimiento:
			push_error("El indicador de primer movimiento no coincide.")
			return false

	print("RESULTADO: CORRECTO")
	return true
