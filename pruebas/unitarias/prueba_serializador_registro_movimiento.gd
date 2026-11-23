
extends RefCounted

const TipoRegistroMovimiento = preload(
    "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_registro_movimiento.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Prueba: SerializadorRegistroMovimiento ---")

	var movimiento = TipoRegistroMovimiento.new()
	movimiento.numero = 1
	movimiento.origen = Vector2i(1, 2)
	movimiento.destino = Vector2i(3, 4)
	movimiento.es_primer_movimiento = true

	var resultado_serializacion = TipoSerializador.serializar(movimiento)

	if not resultado_serializacion.aceptado:
		push_error("Fallo al serializar el movimiento.")
		return false

	var resultado_deserializacion = TipoSerializador.deserializar(
	resultado_serializacion.datos["datos"]
	)

	if not resultado_deserializacion.aceptado:
		print("Codigo de error: ", resultado_deserializacion.codigo)
		print("Datos serializados: ", resultado_serializacion.datos)
		push_error("Fallo al deserializar el movimiento.")
		return false

	var reconstruido = resultado_deserializacion.datos["registro"]

	if reconstruido.numero != movimiento.numero:
		push_error("El numero de movimiento no coincide.")
		return false

	if reconstruido.origen != movimiento.origen:
		push_error("La coordenada de origen no coincide.")
		return false

	if reconstruido.destino != movimiento.destino:
		push_error("La coordenada de destino no coincide.")
		return false

	if reconstruido.es_primer_movimiento != movimiento.es_primer_movimiento:
		push_error("El indicador de primer movimiento no coincide.")
		return false

	print("RESULTADO: CORRECTO")
	return true
