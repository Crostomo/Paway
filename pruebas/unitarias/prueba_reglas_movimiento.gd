
extends RefCounted

const TipoGeometria = preload(
	"res://scripts/datos/modelos/geometria_tablero.gd"
)

const TipoReglasMovimiento = preload(
	"res://scripts/datos/modelos/reglas_movimiento.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- REGLAS DE MOVIMIENTO ---")

	var correctas: bool = true

	var geometria = TipoGeometria.new()
	var reglas = TipoReglasMovimiento.new()

	geometria.configurar_rectangular(9, 9)

	# Caso 1: identidad de las reglas.
	correctas = _comprobar(
		reglas.id_reglas == TipoReglasMovimiento.ID_REGLAS_RECTANGULAR
		and reglas.version_reglas == TipoReglasMovimiento.VERSION_REGLAS_RECTANGULAR,
		"Identifica correctamente el perfil de reglas"
	) and correctas

	# Caso 2: ocho desplazamientos definidos.
	correctas = _comprobar(
		TipoReglasMovimiento.DESPLAZAMIENTOS.size() == 8,
		"Define exactamente ocho desplazamientos"
	) and correctas

	# Casilla central del tablero 9x9: coordenada (4, 4), ID 40.
	var id_origen: int = geometria.obtener_id_casilla(
		Vector2i(4, 4)
	)

	var destinos_esperados: Array[int] = [
		37, 43, 13, 67, 20, 24, 56, 60
	]

	# Caso 3: obtiene los ocho destinos.
	var destinos: Array[int] = reglas.obtener_destinos_validos(
		geometria,
		id_origen
	)

	correctas = _comprobar(
		destinos.size() == 8,
		"Obtiene los ocho destinos desde una casilla central"
	) and correctas

	# Caso 4: comprueba cada destino esperado.
	for id_destino: int in destinos_esperados:
		correctas = _comprobar(
			destinos.has(id_destino),
			"Reconoce el destino con ID " + str(id_destino)
		) and correctas

	# Caso 5: comprueba individualmente los movimientos.
	for id_destino: int in destinos_esperados:
		correctas = _comprobar(
			reglas.es_movimiento_valido(
				geometria,
				id_origen,
				id_destino
			),
			"Valida el movimiento hacia el ID " + str(id_destino)
		) and correctas

	# Caso 6: no permite permanecer en la misma casilla.
	correctas = _comprobar(
		not reglas.es_movimiento_valido(
			geometria,
			id_origen,
			id_origen
		),
		"Rechaza el movimiento hacia la misma casilla"
	) and correctas

	# Caso 7: rechaza un destino que no sigue las reglas.
	correctas = _comprobar(
		not reglas.es_movimiento_valido(
			geometria,
			id_origen,
			geometria.obtener_id_casilla(Vector2i(5, 4))
		),
		"Rechaza un desplazamiento no permitido"
	) and correctas

	# Caso 8: rechaza un origen inexistente.
	correctas = _comprobar(
		reglas.obtener_destinos_validos(geometria, -1).is_empty(),
		"No obtiene destinos desde un origen inexistente"
	) and correctas

	# Caso 9: rechaza un destino inexistente.
	correctas = _comprobar(
		not reglas.es_movimiento_valido(
			geometria,
			id_origen,
			-1
		),
		"Rechaza un destino inexistente"
	) and correctas

	# Caso 10: respeta los limites del tablero.
	var id_esquina: int = geometria.obtener_id_casilla(
		Vector2i(0, 0)
	)

	var destinos_esquina: Array[int] = (
		reglas.obtener_destinos_validos(
			geometria,
			id_esquina
		)
	)

	correctas = _comprobar(
		destinos_esquina.size() == 3
		and destinos_esquina.has(27)
		and destinos_esquina.has(3)
		and destinos_esquina.has(20),
		"Limita correctamente los movimientos desde una esquina"
	) and correctas

	if correctas:
		print("RESULTADO: CORRECTO")
	else:
		print("RESULTADO: ERROR")

	return correctas


static func _comprobar(
	condicion: bool,
	descripcion: String
) -> bool:
	if condicion:
		print("[CORRECTO] ", descripcion)
		return true

	print("[ERROR] ", descripcion)
	return false
