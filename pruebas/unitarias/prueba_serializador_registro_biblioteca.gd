
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

	var registro = TipoRegistroBiblioteca.new()

	registro.version_formato = 1
	registro.id_recorrido = "recorrido_prueba_001"
	registro.tipo_partida = "normal"
	registro.id_reto = ""
	registro.filas = 5
	registro.columnas = 5

	# Recorrido completo de 25 casillas.
	# Cada posicion utiliza x = columna e y = fila.
	var recorrido: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(3, 0),
		Vector2i(3, 3),
		Vector2i(0, 3),
		Vector2i(2, 1),
		Vector2i(2, 4),
		Vector2i(0, 2),
		Vector2i(3, 2),
		Vector2i(1, 0),
		Vector2i(4, 0),
		Vector2i(4, 3),
		Vector2i(1, 3),
		Vector2i(3, 1),
		Vector2i(0, 1),
		Vector2i(0, 4),
		Vector2i(3, 4),
		Vector2i(1, 2),
		Vector2i(4, 2),
		Vector2i(2, 0),
		Vector2i(2, 3),
		Vector2i(4, 1),
		Vector2i(1, 1),
		Vector2i(1, 4),
		Vector2i(4, 4),
		Vector2i(2, 2)
	]

	for posicion in recorrido:
		registro.recorrido.append(posicion)

	registro.fecha_completado = "2026-11-23T12:00:00"
	registro.tiempo_segundos = 125.5
	registro.movimientos_realizados = 30
	registro.movimientos_deshechados = 5
	registro.movimientos_efectivos = 25
	registro.pistas_utilizadas = 2
	registro.favorito = true

	# Serializacion.
	var resultado_serializacion = TipoSerializador.serializar(
		registro
	)

	if resultado_serializacion == null:
		push_error("La serializacion ha devuelto null.")
		return false

	if not resultado_serializacion.aceptado:
		print("Error: ", resultado_serializacion.datos)
		push_error("Fallo al serializar el registro.")
		return false

	var datos_serializados: Dictionary = (
		resultado_serializacion.datos["datos"]
	)

	# Deserializacion.
	var resultado_deserializacion = TipoSerializador.deserializar(
		datos_serializados
	)

	if resultado_deserializacion == null:
		push_error("La deserializacion ha devuelto null.")
		return false

	if not resultado_deserializacion.aceptado:
		print("Error: ", resultado_deserializacion.datos)
		push_error("Fallo al deserializar el registro.")
		return false

	var reconstruido = resultado_deserializacion.datos["registro"]

	# Comprobacion de los datos generales.
	if reconstruido.id_recorrido != registro.id_recorrido:
		push_error("El identificador del recorrido no coincide.")
		return false

	if reconstruido.tipo_partida != registro.tipo_partida:
		push_error("El tipo de partida no coincide.")
		return false

	if reconstruido.id_reto != registro.id_reto:
		push_error("El identificador del reto no coincide.")
		return false

	if reconstruido.filas != registro.filas:
		push_error("El numero de filas no coincide.")
		return false

	if reconstruido.columnas != registro.columnas:
		push_error("El numero de columnas no coincide.")
		return false

	if reconstruido.fecha_completado != registro.fecha_completado:
		push_error("La fecha no coincide.")
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

	# Comprobacion del recorrido completo.
	if reconstruido.recorrido.size() != 25:
		push_error("El recorrido reconstruido no tiene 25 posiciones.")
		return false

	for indice in range(registro.recorrido.size()):
		if reconstruido.recorrido[indice] != registro.recorrido[indice]:
			push_error("No coincide la posicion del recorrido: " + str(indice))
			return false

	# Comprobacion adicional: no debe aceptar posiciones repetidas.
	var datos_invalidos: Dictionary = datos_serializados.duplicate(true)
	datos_invalidos["recorrido"][1] = datos_invalidos["recorrido"][0].duplicate(true)

	var resultado_invalido = TipoSerializador.deserializar(
		datos_invalidos
	)

	if resultado_invalido.aceptado:
		push_error("Se ha aceptado un recorrido con posiciones repetidas.")
		return false

	print("RESULTADO: CORRECTO")
	return true
