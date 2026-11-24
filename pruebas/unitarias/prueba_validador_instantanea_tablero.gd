
extends RefCounted

const TipoInstantaneaTablero = preload(
	"res://scripts/datos/modelos/instantanea_tablero.gd"
)
const TipoEstadoTablero = preload(
	"res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistroMovimiento = preload(
	"res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoValidador = preload(
	"res://scripts/datos/validadores/validador_instantanea_tablero.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Validador de instantanea ---")

	var correctas: int = 0
	var total: int = 6

	var instantanea_preparada := _crear_preparada()
	if TipoValidador.validar(instantanea_preparada).aceptado:
		correctas += 1
		print("CORRECTO: instantanea preparada valida")
	else:
		print("ERROR: instantanea preparada valida")

	var instantanea_activa := _crear_activa()
	if TipoValidador.validar(instantanea_activa).aceptado:
		correctas += 1
		print("CORRECTO: instantanea activa valida")
	else:
		print("ERROR: instantanea activa valida")

	if not TipoValidador.validar(null).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de instantanea nula")
	else:
		print("ERROR: se ha aceptado una instantanea nula")

	var version_incorrecta := _crear_preparada()
	version_incorrecta.version_formato += 1

	if not TipoValidador.validar(version_incorrecta).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de version incompatible")
	else:
		print("ERROR: se ha aceptado una version incompatible")

	var matriz_incorrecta := _crear_preparada()
	matriz_incorrecta.matriz[0][0] = "dato incorrecto"

	if not TipoValidador.validar(matriz_incorrecta).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de matriz incorrecta")
	else:
		print("ERROR: se ha aceptado una matriz incorrecta")

	var contadores_incorrectos := _crear_preparada()
	contadores_incorrectos.movimientos_efectivos = 1

	if not TipoValidador.validar(contadores_incorrectos).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de contadores incoherentes")
	else:
		print("ERROR: se han aceptado contadores incoherentes")

	print("Resultado: ", correctas, "/", total)

	return correctas == total


static func _crear_preparada() -> TipoInstantaneaTablero:
	var instantanea := TipoInstantaneaTablero.new()

	instantanea.filas = 5
	instantanea.columnas = 5
	instantanea.estado = TipoEstadoTablero.ESTADO_PREPARADA
	instantanea.ultima_casilla = Vector2i(-1, -1)

	for fila_numero in range(5):
		var fila: Array = []
		for columna_numero in range(5):
			fila.append(0)
		instantanea.matriz.append(fila)

	return instantanea



static func _crear_activa() -> TipoInstantaneaTablero:
	var instantanea := _crear_preparada()

	instantanea.estado = TipoEstadoTablero.ESTADO_ACTIVA

	# Primer movimiento: fila 0, columna 0.
	instantanea.matriz[0][0] = 1

	# Segundo movimiento: fila 3, columna 0.
	instantanea.matriz[3][0] = 2

	# Tercer movimiento: fila 1, columna 2.
	instantanea.matriz[1][2] = 3

	instantanea.ultima_casilla = Vector2i(2, 1)

	var primero := TipoRegistroMovimiento.new()
	primero.numero = 1
	primero.origen = Vector2i(-1, -1)
	primero.destino = Vector2i(0, 0)
	primero.es_primer_movimiento = true
	instantanea.historial.append(primero)

	var segundo := TipoRegistroMovimiento.new()
	segundo.numero = 2
	segundo.origen = Vector2i(0, 0)
	segundo.destino = Vector2i(0, 3)
	segundo.es_primer_movimiento = false
	instantanea.historial.append(segundo)

	var tercero := TipoRegistroMovimiento.new()
	tercero.numero = 3
	tercero.origen = Vector2i(0, 3)
	tercero.destino = Vector2i(2, 1)
	tercero.es_primer_movimiento = false
	instantanea.historial.append(tercero)

	instantanea.movimientos_realizados = 3
	instantanea.movimientos_deshechos = 0
	instantanea.movimientos_efectivos = 3

	return instantanea
