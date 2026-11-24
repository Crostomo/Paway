
extends RefCounted

const TipoValidador = preload(
    "res://scripts/datos/validadores/validador_dimensiones_tablero.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- VALIDADOR DE DIMENSIONES ---")

	var correctas: bool = true

	# Caso 1: dimensiones mínimas.
	var resultado = TipoValidador.validar(5, 5)
	correctas = _comprobar(
		resultado.aceptado,
        "Dimensiones minimas 5x5"
	) and correctas

	# Caso 2: tablero rectangular válido.
	resultado = TipoValidador.validar(10, 20)
	correctas = _comprobar(
		resultado.aceptado,
        "Tablero rectangular 10x20"
	) and correctas

	# Caso 3: máximo exacto de 500 casillas.
	resultado = TipoValidador.validar(20, 25)
	correctas = _comprobar(
		resultado.aceptado,
        "Maximo exacto de 500 casillas"
	) and correctas

	# Caso 4: filas inferiores al mínimo.
	resultado = TipoValidador.validar(4, 10)
	correctas = _comprobar(
		not resultado.aceptado
		and resultado.codigo == TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        "Rechaza menos de 5 filas"
	) and correctas

	# Caso 5: columnas inferiores al mínimo.
	resultado = TipoValidador.validar(10, 4)
	correctas = _comprobar(
		not resultado.aceptado
		and resultado.codigo == TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        "Rechaza menos de 5 columnas"
	) and correctas

	# Caso 6: más de 500 casillas.
	resultado = TipoValidador.validar(20, 26)
	correctas = _comprobar(
		not resultado.aceptado
		and resultado.codigo == TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
        "Rechaza mas de 500 casillas"
	) and correctas

	if correctas:
		print("RESULTADO: CORRECTO")
	else:
		print("RESULTADO: ERROR")

	return correctas


static func _comprobar(condicion: bool, descripcion: String) -> bool:
	if condicion:
		print("[CORRECTO] ", descripcion)
		return true

	print("[ERROR] ", descripcion)
	return false
