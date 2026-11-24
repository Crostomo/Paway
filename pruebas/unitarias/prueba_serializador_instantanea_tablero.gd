
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

	var instantanea := _crear_instantanea_valida()

	# --------------------------------------------------
	# 1. Serializacion correcta.
	# --------------------------------------------------

	var resultado_serializacion := TipoSerializador.serializar(
		instantanea
	)

	if not resultado_serializacion.aceptado:
		print("Error de serializacion: ", resultado_serializacion.datos)
		push_error("Fallo al serializar la instantanea.")
		return false

	var datos_serializados: Dictionary = (
		resultado_serializacion.datos["datos"]
	)

	if datos_serializados["version_formato"] != 2:
		push_error("La version serializada no es correcta.")
		return false

	# --------------------------------------------------
	# 2. Deserializacion correcta.
	# --------------------------------------------------

	var resultado_deserializacion := TipoSerializador.deserializar(
		datos_serializados
	)

	if not resultado_deserializacion.aceptado:
		print("Error de deserializacion: ", resultado_deserializacion.datos)
		push_error("Fallo al deserializar la instantanea.")
		return false

	var reconstruida = resultado_deserializacion.datos["instantanea"]

	if reconstruida.version_formato != instantanea.version_formato:
		push_error("La version del formato no coincide.")
		return false

	if reconstruida.id_geometria != instantanea.id_geometria:
		push_error("La identidad de geometria no coincide.")
		return false

	if reconstruida.version_geometria != instantanea.version_geometria:
		push_error("La version de geometria no coincide.")
		return false

	if reconstruida.id_reglas_movimiento != instantanea.id_reglas_movimiento:
		push_error("La identidad de reglas no coincide.")
		return false

	if reconstruida.version_reglas_movimiento != instantanea.version_reglas_movimiento:
		push_error("La version de reglas no coincide.")
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

	if reconstruida.ultima_casilla_id != instantanea.ultima_casilla_id:
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

		if original.origen_id != copia.origen_id:
			push_error("El identificador de origen no coincide.")
			return false

		if original.destino_id != copia.destino_id:
			push_error("El identificador de destino no coincide.")
			return false

		if original.es_primer_movimiento != copia.es_primer_movimiento:
			push_error("El indicador de primer movimiento no coincide.")
			return false

	print("[CORRECTO] Serializacion y deserializacion completas.")

	# --------------------------------------------------
	# 3. Rechazos durante la serializacion.
	# --------------------------------------------------

	if not _comprobar_rechazo(
		TipoSerializador.serializar(null),
		"Rechaza instantanea nula"
	):
		return false

	instantanea.filas = 0

	if not _comprobar_rechazo(
		TipoSerializador.serializar(instantanea),
		"Rechaza instantanea con dimensiones invalidas"
	):
		return false

	# --------------------------------------------------
	# 4. Rechazos durante la deserializacion.
	# --------------------------------------------------

	var datos: Dictionary

	datos = datos_serializados.duplicate(true)
	datos.erase("version_formato")

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza version de formato ausente"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["version_formato"] = "2"

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza version de formato con tipo incorrecto"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["version_formato"] = 1

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza formato 1"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["version_formato"] = 3

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza formato futuro"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["filas"] = 0

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza dimensiones invalidas"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["id_geometria"] = ""

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza identidad de geometria vacia"
	):
		return false

	datos = datos_serializados.duplicate(true)
	datos["id_reglas_movimiento"] = ""

	if not _comprobar_rechazo(
		TipoSerializador.deserializar(datos),
		"Rechaza identidad de reglas vacia"
	):
		return false

	print("")
	print("RESULTADO: CORRECTO")
	return true


static func _crear_instantanea_valida() -> TipoInstantanea:
	var instantanea := TipoInstantanea.new()

	instantanea.version_formato = 2
	instantanea.filas = 5
	instantanea.columnas = 5

	instantanea.matriz.clear()

	for fila in range(instantanea.filas):
		var nueva_fila: Array[int] = []

		for columna in range(instantanea.columnas):
			nueva_fila.append(0)

		instantanea.matriz.append(nueva_fila)

	# Recorrido valido de tres movimientos.
	instantanea.matriz[2][3] = 1
	instantanea.matriz[2][0] = 2
	instantanea.matriz[4][2] = 3

	var primero := TipoRegistroMovimiento.new()
	primero.numero = 1
	primero.origen_id = -1
	primero.destino_id = 13
	primero.es_primer_movimiento = true
	instantanea.historial.append(primero)

	var segundo := TipoRegistroMovimiento.new()
	segundo.numero = 2
	segundo.origen_id = 13
	segundo.destino_id = 10
	segundo.es_primer_movimiento = false
	instantanea.historial.append(segundo)

	var tercero := TipoRegistroMovimiento.new()
	tercero.numero = 3
	tercero.origen_id = 10
	tercero.destino_id = 22
	tercero.es_primer_movimiento = false
	instantanea.historial.append(tercero)

	instantanea.ultima_casilla_id = 22
	instantanea.estado = TipoEstadoTablero.ESTADO_ACTIVA
	instantanea.movimientos_realizados = 3
	instantanea.movimientos_deshechos = 0
	instantanea.movimientos_efectivos = 3

	return instantanea


static func _comprobar_rechazo(
	resultado,
	descripcion: String
) -> bool:
	if resultado.aceptado:
		print("[ERROR] ", descripcion)
		push_error(descripcion)
		return false

	print("[CORRECTO] ", descripcion)
	return true
