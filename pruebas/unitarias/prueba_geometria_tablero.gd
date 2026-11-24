
extends RefCounted

const TipoGeometria = preload(
	"res://scripts/datos/modelos/geometria_tablero.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- GEOMETRIA DEL TABLERO ---")

	var correctas: bool = true
	var geometria = TipoGeometria.new()

	# Caso 1: configuracion rectangular 5x5.
	correctas = _comprobar(
		geometria.configurar_rectangular(5, 5),
		"Configura correctamente un tablero 5x5"
	) and correctas

	# Caso 2: identificacion de la geometria.
	correctas = _comprobar(
		geometria.id_geometria == TipoGeometria.GEOMETRIA_RECTANGULAR
		and geometria.version_geometria == TipoGeometria.VERSION_RECTANGULAR,
		"Identifica la geometria rectangular y su version"
	) and correctas

	# Caso 3: dimensiones configuradas.
	correctas = _comprobar(
		geometria.filas == 5 and geometria.columnas == 5,
		"Conserva las dimensiones del tablero"
	) and correctas

	# Caso 4: numero total de casillas.
	correctas = _comprobar(
		geometria.obtener_total_casillas() == 25,
		"Calcula correctamente las 25 casillas"
	) and correctas

	# Caso 5: coordenada inicial.
	correctas = _comprobar(
		geometria.obtener_id_casilla(Vector2i(0, 0)) == 0,
		"Convierte la primera coordenada en el ID 0"
	) and correctas

	# Caso 6: coordenada final.
	correctas = _comprobar(
		geometria.obtener_id_casilla(Vector2i(4, 4)) == 24,
		"Convierte la ultima coordenada en el ID 24"
	) and correctas

	# Caso 7: conversion inversa.
	correctas = _comprobar(
		geometria.obtener_coordenadas_casilla(12) == Vector2i(2, 2),
		"Convierte el ID 12 en la coordenada central"
	) and correctas

	# Caso 8: coordenadas fuera del tablero.
	correctas = _comprobar(
		not geometria.contiene_coordenada(Vector2i(5, 2))
		and not geometria.contiene_coordenada(Vector2i(2, 5))
		and not geometria.contiene_coordenada(Vector2i(-1, 0)),
		"Rechaza coordenadas fuera de los limites"
	) and correctas

	# Caso 9: identificadores fuera del tablero.
	correctas = _comprobar(
		not geometria.contiene_id_casilla(-1)
		and not geometria.contiene_id_casilla(25),
		"Rechaza identificadores fuera de los limites"
	) and correctas

	# Caso 10: conversion de identificador invalido.
	correctas = _comprobar(
		geometria.obtener_coordenadas_casilla(-1) == Vector2i(-1, -1)
		and geometria.obtener_coordenadas_casilla(25) == Vector2i(-1, -1),
		"Devuelve coordenadas invalidas para IDs inexistentes"
	) and correctas

	# Caso 11: conversion de coordenada invalida.
	correctas = _comprobar(
		geometria.obtener_id_casilla(Vector2i(5, 0)) == -1,
		"Devuelve -1 para una coordenada inexistente"
	) and correctas

	# Caso 12: dimensiones cero.
	correctas = _comprobar(
		not geometria.configurar_rectangular(0, 5),
		"Rechaza dimensiones con cero filas"
	) and correctas

	# Caso 13: dimensiones negativas.
	correctas = _comprobar(
		not geometria.configurar_rectangular(5, -1),
		"Rechaza dimensiones negativas"
	) and correctas

	if correctas:
		print("RESULTADO: CORRECTO")
	else:
		print("RESULTADO: ERROR")

	return correctas

	# Caso 14: conserva la configuracion anterior si falla una nueva.
	correctas = _comprobar(
			not geometria.configurar_rectangular(0, 5)
			and geometria.filas == 5
			and geometria.columnas == 5
			and geometria.obtener_total_casillas() == 25,
			"Conserva la geometria anterior si falla una configuracion"
	) and correctas

static func _comprobar(
	condicion: bool,
	descripcion: String
) -> bool:
	if condicion:
		print("[CORRECTO] ", descripcion)
		return true

	print("[ERROR] ", descripcion)
	return false
