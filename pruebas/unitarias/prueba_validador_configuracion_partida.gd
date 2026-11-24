
extends RefCounted

const TipoConfiguracion = preload(
    "res://scripts/datos/modelos/configuracion_partida.gd"
)
const TipoValidador = preload(
    "res://scripts/datos/validadores/validador_configuracion_partida.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- VALIDADOR DE CONFIGURACION DE PARTIDA ---")

	var correctas: bool = true
	
	var configuracion = TipoConfiguracion.new()
	configuracion.filas = 5
	configuracion.columnas = 5
	
	var resultado

	# 1. Partida normal válida.
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Partida normal valida"
	) and correctas

	# 2. Partida personalizada válida.
	configuracion.tipo_partida = TipoConfiguracion.TIPO_PERSONALIZADA
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Partida personalizada valida"
	) and correctas

	# 3. Partida de reto válida.
	configuracion.tipo_partida = TipoConfiguracion.TIPO_RETO
	configuracion.id_reto = "RETO_001"
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Partida de reto con identificador"
	) and correctas

	# 4. Reto sin identificador.
	configuracion.id_reto = "   "
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza reto sin identificador"
	) and correctas

	# 5. Identificador de reto en partida normal.
	configuracion.tipo_partida = TipoConfiguracion.TIPO_NORMAL
	configuracion.id_reto = "RETO_001"
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza identificador de reto en partida normal"
	) and correctas

	# 6. Espacios en identificador de reto en partida normal.
	configuracion.id_reto = "   "
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta identificador vacio con espacios en partida normal"
	) and correctas

	# 7. Tipo de partida desconocido.
	configuracion.id_reto = ""
	configuracion.tipo_partida = "desconocida"
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza tipo de partida desconocido"
	) and correctas

	# 8. Dimensiones no válidas.
	configuracion.tipo_partida = TipoConfiguracion.TIPO_NORMAL
	configuracion.filas = 4
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza dimensiones no validas"
	) and correctas

	# Restaurar dimensiones.
	configuracion.filas = 5

	# 9. Restricción de inicio válida.
	configuracion.inicio_permitido.append(Vector2i(0, 0))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta inicio permitido dentro del tablero"
	) and correctas

	# 10. Restricción de inicio fuera del tablero.
	configuracion.inicio_permitido.clear()
	configuracion.inicio_permitido.append(Vector2i(5, 0))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza inicio fuera del tablero"
	) and correctas

	# 11. Restricción de inicio duplicada.
	configuracion.inicio_permitido.clear()
	configuracion.inicio_permitido.append(Vector2i(1, 1))
	configuracion.inicio_permitido.append(Vector2i(1, 1))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza inicio duplicado"
	) and correctas

	# 12. Restricción de final válida.
	configuracion.inicio_permitido.clear()
	configuracion.final_permitido.append(Vector2i(4, 4))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta final permitido dentro del tablero"
	) and correctas

	# 13. Restricción de final fuera del tablero.
	configuracion.final_permitido.clear()
	configuracion.final_permitido.append(Vector2i(0, 5))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza final fuera del tablero"
	) and correctas

	# 14. Restricción de final duplicada.
	configuracion.final_permitido.clear()
	configuracion.final_permitido.append(Vector2i(2, 2))
	configuracion.final_permitido.append(Vector2i(2, 2))
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza final duplicado"
	) and correctas

	# 15. Restricciones libres.
	configuracion.final_permitido.clear()
	configuracion.inicio_permitido.clear()
	resultado = TipoValidador.validar(configuracion)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta inicio y final libres"
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
