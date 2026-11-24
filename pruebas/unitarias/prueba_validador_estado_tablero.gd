
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

	# 1. Estado preparado valido.
	estado = _crear_estado_preparado()
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
			resultado.aceptado,
			"Acepta tablero preparado"
	) and correctas

	# 2. Estado activo valido con tres movimientos.
	estado = _crear_estado_activo()
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
			resultado.aceptado,
			"Acepta tablero activo coherente"
	) and correctas

	# 3. Geometria desconocida.
	estado = _crear_estado_activo()
	estado.id_geometria = "geometria_desconocida"
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza geometria desconocida"
	) and correctas

	# 4. Version de geometria incompatible.
	estado = _crear_estado_activo()
	estado.version_geometria = 99
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza version de geometria incompatible"
	) and correctas

	# 5. Reglas de movimiento desconocidas.
	estado = _crear_estado_activo()
	estado.id_reglas_movimiento = "reglas_desconocidas"
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza reglas de movimiento desconocidas"
	) and correctas

	# 6. Version de reglas incompatible.
	estado = _crear_estado_activo()
	estado.version_reglas_movimiento = 99
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza version de reglas incompatible"
	) and correctas

	# 7. Número de filas incorrecto.
	estado = _crear_estado_activo()
	estado.matriz.remove_at(4)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza numero de filas incorrecto"
	) and correctas

	# 8. Número de columnas incorrecto.
	estado = _crear_estado_activo()
	estado.matriz[0].remove_at(4)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza numero de columnas incorrecto"
	) and correctas

	# 9. Valor no entero.
	estado = _crear_estado_activo()
	estado.matriz[0][0] = "texto"
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza valor de casilla no entero"
	) and correctas

	# 10. Número negativo.
	estado = _crear_estado_activo()
	estado.matriz[0][0] = -1
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza numero negativo"
	) and correctas

	# 11. Número repetido.
	estado = _crear_estado_activo()
	estado.matriz[0][1] = 1
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza numero de casilla duplicado"
	) and correctas

	# 12. Secuencia incompleta.
	estado = _crear_estado_activo()
	estado.matriz[0][3] = 0
	estado.matriz[0][2] = 2
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza secuencia numerica incompleta"
	) and correctas

	# 13. Historial que no coincide con el tablero.
	estado = _crear_estado_activo()
	estado.historial.remove_at(2)
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza historial incompleto"
	) and correctas

	# 14. Última casilla incorrecta.
	estado = _crear_estado_activo()
	estado.ultima_casilla_id = 0
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza ultima casilla incorrecta"
	) and correctas

	# 15. Origen del primer movimiento incorrecto.
	estado = _crear_estado_activo()
	estado.historial[0].origen_id = 0
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza origen incorrecto del primer movimiento"
	) and correctas

	# 16. Origen de un movimiento posterior incorrecto.
	estado = _crear_estado_activo()
	estado.historial[1].origen_id = 6
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza origen incorrecto en historial"
	) and correctas

	# 17. Desplazamiento no permitido.
	# ID 3 corresponde a (3,0).
	# ID 2 corresponde a (2,0): desplazamiento de una columna.
	estado = _crear_estado_activo()
	estado.historial[2].destino_id = 2
	estado.matriz[2][1] = 0
	estado.matriz[0][2] = 3
	estado.ultima_casilla_id = 2
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza desplazamiento no permitido"
	) and correctas

	# 18. Contadores incoherentes.
	estado = _crear_estado_activo()
	estado.movimientos_efectivos = 2
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza contadores incoherentes"
	) and correctas

	# 19. Estado activo sin movimientos.
	estado = _crear_estado_preparado()
	estado.estado = TipoEstado.ESTADO_ACTIVA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza estado activo sin movimientos"
	) and correctas

	# 20. Estado bloqueado sin movimientos.
	estado = _crear_estado_preparado()
	estado.estado = TipoEstado.ESTADO_BLOQUEADA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza estado bloqueado sin movimientos"
	) and correctas

	# 21. Estado bloqueado con destinos validos.
	estado = _crear_estado_activo()
	estado.estado = TipoEstado.ESTADO_BLOQUEADA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza estado bloqueado con destinos validos"
	) and correctas

	# 22. Estado completado con tablero incompleto.
	estado = _crear_estado_activo()
	estado.estado = TipoEstado.ESTADO_COMPLETADA
	resultado = TipoValidador.validar(estado)
	correctas = _comprobar(
		not resultado.aceptado,
		"Rechaza estado completado incompleto"
	) and correctas

	# 23. Todos los movimientos deshechos.
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
	var estado := TipoEstado.new()

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
	var estado := _crear_estado_preparado()

	# IDs: (0,0) = 0; (3,0) = 3; (1,2) = 11.
	var destinos: Array[int] = [0, 3, 11]

	for indice in range(destinos.size()):
		var destino_id: int = destinos[indice]
		var coordenadas: Vector2i = Vector2i(
			destino_id % estado.columnas,
			destino_id / estado.columnas
		)

		estado.matriz[coordenadas.y][coordenadas.x] = indice + 1

		var registro := TipoRegistro.new()
		registro.numero = indice + 1
		registro.destino_id = destino_id

		if indice == 0:
			registro.origen_id = -1
			registro.es_primer_movimiento = true
		else:
			registro.origen_id = destinos[indice - 1]

		estado.historial.append(registro)

	estado.ultima_casilla_id = destinos[2]
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
