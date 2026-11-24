
extends RefCounted

const TipoRegistroBiblioteca = preload(
    "res://scripts/datos/modelos/registro_biblioteca.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_registro_biblioteca.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorRegistroBiblioteca ---")

	var registro = _crear_registro()

	# --------------------------------------------------
	# 1. Serializacion y deserializacion.
	# --------------------------------------------------

	print("DIAGNOSTICO DEL REGISTRO:")
	print("Formato: ", registro.version_formato)
	print("Geometria: ", registro.id_geometria, " / ", registro.version_geometria)
	print("Reglas: ", registro.id_reglas_movimiento, " / ", registro.version_reglas_movimiento)
	print("ID recorrido: ", registro.id_recorrido)
	print("Tipo partida: ", registro.tipo_partida)
	print("Dimensiones: ", registro.filas, " x ", registro.columnas)
	print("Numero de casillas: ", registro.recorrido.size())
	print("Recorrido: ", registro.recorrido)
	print("Fecha: ", registro.fecha_completado)
	print("Tiempo: ", registro.tiempo_segundos)
	print("Movimientos: ", registro.movimientos_realizados, " / ", registro.movimientos_deshechados, " / ", registro.movimientos_efectivos)
	print("Pistas: ", registro.pistas_utilizadas)

	var resultado_serializacion = TipoSerializador.serializar(registro)

	if resultado_serializacion == null :
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("DETALLE DEL RECHAZO: ", resultado_serializacion.datos)
		push_error("No se ha podido serializar el registro.")
		return false

	var datos_serializados: Dictionary = (
		resultado_serializacion.datos["datos"]
	)

	if datos_serializados["version_formato"] != 2:
		push_error("La version del formato no es la esperada.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
		datos_serializados
	)

	if resultado_deserializacion == null or not resultado_deserializacion.aceptado:
		push_error("No se ha podido deserializar el registro.")
		return false

	var reconstruido = resultado_deserializacion.datos["registro"]

	if reconstruido.id_geometria != registro.id_geometria:
		push_error("El identificador de geometria no coincide.")
		return false

	if reconstruido.version_geometria != registro.version_geometria:
		push_error("La version de geometria no coincide.")
		return false

	if reconstruido.id_reglas_movimiento != registro.id_reglas_movimiento:
		push_error("El identificador de reglas no coincide.")
		return false

	if reconstruido.version_reglas_movimiento != registro.version_reglas_movimiento:
		push_error("La version de reglas no coincide.")
		return false

	if reconstruido.id_recorrido != registro.id_recorrido:
		push_error("El identificador del recorrido no coincide.")
		return false

	if reconstruido.tipo_partida != registro.tipo_partida:
		push_error("El tipo de partida no coincide.")
		return false

	if reconstruido.id_reto != registro.id_reto:
		push_error("El identificador del reto no coincide.")
		return false

	if reconstruido.filas != registro.filas or reconstruido.columnas != registro.columnas:
		push_error("Las dimensiones no coinciden.")
		return false

	if reconstruido.recorrido.size() != registro.recorrido.size():
		push_error("La longitud del recorrido no coincide.")
		return false

	for indice in range(registro.recorrido.size()):
		if reconstruido.recorrido[indice] != registro.recorrido[indice]:
			push_error("No coincide la posicion del recorrido: " + str(indice))
			return false

	if reconstruido.fecha_completado != registro.fecha_completado:
		push_error("La fecha de finalizacion no coincide.")
		return false

	if reconstruido.tiempo_segundos != registro.tiempo_segundos:
		push_error("El tiempo no coincide.")
		return false

	if reconstruido.movimientos_realizados != registro.movimientos_realizados:
		push_error("Los movimientos realizados no coinciden.")
		return false

	if reconstruido.movimientos_deshechados != registro.movimientos_deshechados:
		push_error("Los movimientos deshechos no coinciden.")
		return false

	if reconstruido.movimientos_efectivos != registro.movimientos_efectivos:
		push_error("Los movimientos efectivos no coinciden.")
		return false

	if reconstruido.pistas_utilizadas != registro.pistas_utilizadas:
		push_error("Las pistas utilizadas no coinciden.")
		return false

	if reconstruido.favorito != registro.favorito:
		push_error("El estado de favorito no coincide.")
		return false

	# --------------------------------------------------
	# 2. Rechazo de datos incorrectos al deserializar.
	# --------------------------------------------------

	# Recorrido con casilla repetida.
	var datos = datos_serializados.duplicate(true)
	var recorrido: Array = datos["recorrido"].duplicate()
	recorrido[1] = 0
	datos["recorrido"] = recorrido

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado una casilla repetida.")
		return false

	# Geometria no implementada.
	datos = datos_serializados.duplicate(true)
	datos["id_geometria"] = "hexagonal"

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado una geometria no implementada.")
		return false

	# Version de geometria no implementada.
	datos = datos_serializados.duplicate(true)
	datos["version_geometria"] = 99

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado una version de geometria desconocida.")
		return false

	# Reglas no implementadas.
	datos = datos_serializados.duplicate(true)
	datos["id_reglas_movimiento"] = "reglas_futuras"

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se han aceptado reglas no implementadas.")
		return false

	# Formato futuro.
	datos = datos_serializados.duplicate(true)
	datos["version_formato"] = 3

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un formato futuro incompatible.")
		return false

	# Version de formato ausente.
	datos = datos_serializados.duplicate(true)
	datos.erase("version_formato")

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un registro sin version de formato.")
		return false

	# Campo obligatorio ausente.
	datos = datos_serializados.duplicate(true)
	datos.erase("id_recorrido")

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un registro sin identificador de recorrido.")
		return false

	# Tipo de dato incorrecto.
	datos = datos_serializados.duplicate(true)
	datos["filas"] = "cinco"

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un tipo de dato incorrecto.")
		return false

	# ID negativo.
	datos = datos_serializados.duplicate(true)
	recorrido = datos["recorrido"].duplicate()
	recorrido[0] = -1
	datos["recorrido"] = recorrido

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un ID negativo.")
		return false

	# ID fuera de rango.
	datos = datos_serializados.duplicate(true)
	recorrido = datos["recorrido"].duplicate()
	recorrido[0] = 25
	datos["recorrido"] = recorrido

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un ID fuera del tablero.")
		return false

	# Movimiento no permitido.
	datos = datos_serializados.duplicate(true)
	recorrido = datos["recorrido"].duplicate()
	recorrido[1] = 1
	datos["recorrido"] = recorrido

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado un movimiento no permitido.")
		return false

	# --------------------------------------------------
	# 3. Rechazo de registros invalidos al serializar.
	# --------------------------------------------------

	var registro_invalido = _crear_registro()
	registro_invalido.recorrido[0] = -1

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un registro con un ID negativo.")
		return false

	registro_invalido = _crear_registro()
	registro_invalido.recorrido[1] = 0

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un recorrido con casillas repetidas.")
		return false

	registro_invalido = _crear_registro()
	registro_invalido.recorrido[1] = 1

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un movimiento no permitido.")
		return false

	registro_invalido = _crear_registro()
	registro_invalido.tiempo_segundos = -1.0

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un tiempo negativo.")
		return false

	registro_invalido = _crear_registro()
	registro_invalido.tiempo_segundos = NAN

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un tiempo NAN.")
		return false

	registro_invalido = _crear_registro()
	registro_invalido.tiempo_segundos = INF

	if not _debe_rechazar_serializacion(registro_invalido):
		push_error("Se ha serializado un tiempo infinito.")
		return false

	# --------------------------------------------------
	# 4. Migracion del formato antiguo 1.
	# --------------------------------------------------

	var datos_formato_antiguo = datos_serializados.duplicate(true)

	datos_formato_antiguo["version_formato"] = 1

	datos_formato_antiguo.erase("id_geometria")
	datos_formato_antiguo.erase("version_geometria")
	datos_formato_antiguo.erase("id_reglas_movimiento")
	datos_formato_antiguo.erase("version_reglas_movimiento")

	var recorrido_antiguo: Array = []

	for id_casilla: int in registro.recorrido:
		recorrido_antiguo.append({
			"x": id_casilla % registro.columnas,
			"y": int(id_casilla / registro.columnas)
		})

	datos_formato_antiguo["recorrido"] = recorrido_antiguo

	var resultado_migracion = TipoSerializador.deserializar(
		datos_formato_antiguo
	)

	if resultado_migracion == null or not resultado_migracion.aceptado:
		push_error("No se ha podido migrar el formato antiguo.")
		return false

	var registro_migrado = resultado_migracion.datos["registro"]

	if registro_migrado.version_formato != 2:
		push_error("El registro migrado no utiliza el formato 2.")
		return false

	if registro_migrado.id_geometria != "rectangular":
		push_error("La geometria migrada no es la esperada.")
		return false

	if registro_migrado.version_geometria != 1:
		push_error("La version de geometria migrada no es correcta.")
		return false

	if registro_migrado.id_reglas_movimiento != "rectangular_saltos_3_2":
		push_error("Las reglas migradas no son las esperadas.")
		return false

	if registro_migrado.version_reglas_movimiento != 1:
		push_error("La version de reglas migrada no es correcta.")
		return false

	for indice in range(registro.recorrido.size()):
		if registro_migrado.recorrido[indice] != registro.recorrido[indice]:
			push_error("La migracion ha alterado el recorrido.")
			return false

	# Coordenada fuera de rango durante la migracion.
	datos = datos_formato_antiguo.duplicate(true)
	recorrido_antiguo = datos["recorrido"].duplicate(true)
	recorrido_antiguo[0]["x"] = 5
	datos["recorrido"] = recorrido_antiguo

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado una coordenada antigua fuera de rango.")
		return false

	# Coordenada incompleta durante la migracion.
	datos = datos_formato_antiguo.duplicate(true)
	recorrido_antiguo = datos["recorrido"].duplicate(true)
	recorrido_antiguo[0].erase("y")
	datos["recorrido"] = recorrido_antiguo

	if not _debe_rechazar_deserializacion(datos):
		push_error("Se ha aceptado una coordenada antigua incompleta.")
		return false

	print("RESULTADO: CORRECTO")
	return true


static func _debe_rechazar_deserializacion(datos: Dictionary) -> bool:
	var resultado = TipoSerializador.deserializar(datos)

	if resultado == null:
		return true

	return not resultado.aceptado


static func _debe_rechazar_serializacion(registro) -> bool:
	var resultado = TipoSerializador.serializar(registro)

	if resultado == null:
		return true

	return not resultado.aceptado


static func _crear_registro() -> TipoRegistroBiblioteca:
	var registro = TipoRegistroBiblioteca.new()

	registro.version_formato = 2
	registro.id_geometria = "rectangular"
	registro.version_geometria = 1
	registro.id_reglas_movimiento = "rectangular_saltos_3_2"
	registro.version_reglas_movimiento = 1

	registro.id_recorrido = "recorrido_prueba_001"
	registro.tipo_partida = "normal"
	registro.id_reto = ""
	registro.filas = 5
	registro.columnas = 5

	var recorrido: Array[int] = [
		0, 3, 18, 15, 7,
		22, 14, 11, 23, 20,
		5, 8, 16, 19, 4,
		1, 13, 10, 2, 17,
		9, 6, 21, 24, 12
	]

	registro.recorrido = recorrido
	registro.fecha_completado = "2026-11-23T12:00:00"
	registro.tiempo_segundos = 125.5
	registro.movimientos_realizados = 30
	registro.movimientos_deshechados = 5
	registro.movimientos_efectivos = 25
	registro.pistas_utilizadas = 2
	registro.favorito = true

	return registro
