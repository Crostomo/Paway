
extends RefCounted

const TipoEstado = preload(
    "res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistro = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoValidador = preload(
    "res://scripts/datos/validadores/validador_estado_tablero.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- VALIDADOR DE ESTADO DEL TABLERO ---")

	var correctas: bool = true
	var estado
	var resultado

	# 1. Estado preparado válido.
	estado = _crear_estado_preparado()
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta tablero preparado"
	) and correctas

	# 2. Estado activo válido con tres movimientos.
	estado = _crear_estado_activo()
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta tablero activo coherente"
	) and correctas

	# 3. Número de filas incorrecto.
	estado = _crear_estado_activo()
	estado.matriz.remove_at(4)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza numero de filas incorrecto"
	) and correctas

	# 4. Número de columnas incorrecto.
	estado = _crear_estado_activo()
	estado.matriz[0].remove_at(4)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza numero de columnas incorrecto"
	) and correctas

	# 5. Valor no entero.
	estado = _crear_estado_activo()
	estado.matriz[0][0] = "texto"
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza valor de casilla no entero"
	) and correctas

	# 6. Número negativo.
	estado = _crear_estado_activo()
	estado.matriz[0][0] = -1
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza numero negativo"
	) and correctas

	# 7. Número repetido.
	estado = _crear_estado_activo()
	estado.matriz[0][1] = 1
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza numero repetido"
	) and correctas

	# 8. Secuencia incompleta.
	estado = _crear_estado_activo()
	estado.matriz[0][3] = 0
	estado.matriz[0][2] = 2
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza secuencia numerica incompleta"
	) and correctas

	# 9. Historial que no coincide con el tablero.
	estado = _crear_estado_activo()
	estado.historial.remove_at(2)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza historial incompleto"
	) and correctas

	# 10. Última casilla incorrecta.
	estado = _crear_estado_activo()
	estado.ultima_casilla = Vector2i(0, 0)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza ultima casilla incorrecta"
	) and correctas

	# 11. Origen del primer movimiento incorrecto.
	estado = _crear_estado_activo()
	estado.historial[0].origen = Vector2i(0, 0)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza origen incorrecto del primer movimiento"
	) and correctas

	# 12. Origen de un movimiento posterior incorrecto.
	estado = _crear_estado_activo()
	estado.historial[1].origen = Vector2i(1, 1)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza origen incorrecto en historial"
	) and correctas

	# 13. Desplazamiento no permitido.
	estado = _crear_estado_activo()
	estado.historial[2].destino = Vector2i(2, 0)
	estado.matriz[2][2] = 3
	estado.ultima_casilla = Vector2i(2, 0)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza desplazamiento no permitido"
	) and correctas

	# 14. Contadores incoherentes.
	estado = _crear_estado_activo()
	estado.movimientos_efectivos = 2
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza contadores incoherentes"
	) and correctas

	# 15. Estado activo sin movimientos.
	estado = _crear_estado_preparado()
	estado.estado = TipoEstado.ESTADO_ACTIVA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza estado activo sin movimientos"
	) and correctas

	# 16. Estado bloqueado sin movimientos.
	estado = _crear_estado_preparado()
	estado.estado = TipoEstado.ESTADO_BLOQUEADA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza estado bloqueado sin movimientos"
	) and correctas

	# 17. Estado completado con tablero incompleto.
	estado = _crear_estado_activo()
	estado.estado = TipoEstado.ESTADO_COMPLETADA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
        "Rechaza estado completado incompleto"
	) and correctas

	# 18. Todos los movimientos deshechos.
	estado = _crear_estado_preparado()
	estado.movimientos_realizados = 3
	estado.movimientos_deshechos = 3
	estado.movimientos_efectivos = 0
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		resultado.aceptado,
        "Acepta tablero vacio tras deshacer todos los movimientos"
	) and correctas

	if correctas:
		print("RESULTADO: CORRECTO")
	else:
		print("RESULTADO: ERROR")

	return correctas


static func _crear_estado_preparado() -> TipoEstado:
	var estado = TipoEstado.new()

	estado.filas = 5
	estado.columnas = 5
	estado.estado = TipoEstado.ESTADO_PREPARADA

	for fila in range(5):
		var fila_actual: Array = []

		for columna in range(5):
			fila_actual.append(0)

		estado.matriz.append(fila_actual)

	return estado


static func _crear_estado_activo() -> TipoEstado:
	var estado = _crear_estado_preparado()

	var posiciones: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(3, 0),
		Vector2i(1, 2)
	]

	for indice in range(posiciones.size()):
		var destino: Vector2i = posiciones[indice]
		estado.matriz[destino.y][destino.x] = indice + 1

		var registro = TipoRegistro.new()
		registro.numero = indice + 1
		registro.destino = destino

		if indice == 0:
			registro.origen = Vector2i(-1, -1)
			registro.es_primer_movimiento = true
		else:
			registro.origen = posiciones[indice - 1]

		estado.historial.append(registro)

	estado.ultima_casilla = posiciones[2]
	estado.estado = TipoEstado.ESTADO_ACTIVA
	estado.movimientos_realizados = 3
	estado.movimientos_deshechos = 0
	estado.movimientos_efectivos = 3

	return estado


static func _comprobar(condicion: bool, descripcion: String) -> bool:
	if condicion:
		print("[CORRECTO] ", descripcion)
		return true

	print("[ERROR] ", descripcion)
	return false
