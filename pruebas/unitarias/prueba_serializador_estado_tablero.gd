
extends RefCounted

const TipoEstadoTablero = preload(
    "res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_estado_tablero.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorEstadoTablero ---")

	var estado = TipoEstadoTablero.new()

	estado.filas = 5
	estado.columnas = 5
	estado.matriz.clear()

	for fila in range(estado.filas):
		var nueva_fila: Array[int] = []

		for columna in range(estado.columnas):
			nueva_fila.append(0)

		estado.matriz.append(nueva_fila)

	estado.matriz[2][3] = 1
	estado.matriz[2][0] = 2
	estado.matriz[4][2] = 3

	# Primer movimiento: fila 2, columna 3.
	var primero = TipoRegistroMovimiento.new()
	primero.numero = 1
	primero.origen = Vector2i(-1, -1)
	primero.destino = Vector2i(3, 2)
	primero.es_primer_movimiento = true
	estado.historial.append(primero)

	# Segundo movimiento: tres columnas a la izquierda.
	var segundo = TipoRegistroMovimiento.new()
	segundo.numero = 2
	segundo.origen = Vector2i(3, 2)
	segundo.destino = Vector2i(0, 2)
	segundo.es_primer_movimiento = false
	estado.historial.append(segundo)

	# Tercer movimiento: dos filas y dos columnas en diagonal.
	var tercero = TipoRegistroMovimiento.new()
	tercero.numero = 3
	tercero.origen = Vector2i(0, 2)
	tercero.destino = Vector2i(2, 4)
	tercero.es_primer_movimiento = false
	estado.historial.append(tercero)

	estado.ultima_casilla = Vector2i(2, 4)
	estado.estado = TipoEstadoTablero.ESTADO_ACTIVA
	estado.movimientos_realizados = 3
	estado.movimientos_deshechos = 0
	estado.movimientos_efectivos = 3

	var resultado_serializacion = TipoSerializador.serializar(estado)

	if not resultado_serializacion.aceptado:
		print("Error de serializacion: ", resultado_serializacion.datos)
		push_error("Fallo al serializar el tablero.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		resultado_serializacion.datos["datos"]
	)

	if not resultado_deserializacion.aceptado:
		print("Error de deserializacion: ", resultado_deserializacion.datos)
		push_error("Fallo al deserializar el tablero.")
		return false

	var reconstruido = resultado_deserializacion.datos["estado_tablero"]

	if reconstruido.filas != estado.filas:
		push_error("El numero de filas no coincide.")
		return false

	if reconstruido.columnas != estado.columnas:
		push_error("El numero de columnas no coincide.")
		return false

	if reconstruido.matriz != estado.matriz:
		push_error("La matriz no coincide.")
		return false

	if reconstruido.historial.size() != estado.historial.size():
		push_error("El historial no coincide.")
		return false

	if reconstruido.ultima_casilla != estado.ultima_casilla:
		push_error("La ultima casilla no coincide.")
		return false

	if reconstruido.estado != estado.estado:
		push_error("El estado no coincide.")
		return false

	if reconstruido.movimientos_realizados != estado.movimientos_realizados:
		push_error("El contador de movimientos realizados no coincide.")
		return false

	if reconstruido.movimientos_deshechos != estado.movimientos_deshechos:
		push_error("El contador de movimientos deshechos no coincide.")
		return false

	if reconstruido.movimientos_efectivos != estado.movimientos_efectivos:
		push_error("El contador de movimientos efectivos no coincide.")
		return false

	for indice in range(estado.historial.size()):
		var original = estado.historial[indice]
		var copia = reconstruido.historial[indice]

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
