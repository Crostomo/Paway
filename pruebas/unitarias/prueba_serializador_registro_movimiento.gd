
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

		var correctas: bool = true
		var movimiento := TipoRegistroMovimiento.new()

		# 1. Serialización y deserialización de un primer movimiento válido.
		movimiento.numero = 1
		movimiento.origen_id = -1
		movimiento.destino_id = 13
		movimiento.es_primer_movimiento = true

		var resultado_serializacion := TipoSerializador.serializar(
				movimiento
		)

		correctas = _comprobar(
				resultado_serializacion.aceptado,
                "Serializa primer movimiento valido"
		) and correctas

		if resultado_serializacion.aceptado:
				var datos_serializados: Dictionary = (
						resultado_serializacion.datos["datos"]
				)

				correctas = _comprobar(
						datos_serializados["version_formato"] == 2,
                        "Utiliza formato 2"
				) and correctas

				var resultado_deserializacion := (
						TipoSerializador.deserializar(datos_serializados)
				)

				correctas = _comprobar(
						resultado_deserializacion.aceptado,
                        "Deserializa primer movimiento valido"
				) and correctas

				if resultado_deserializacion.aceptado:
						var reconstruido = (
								resultado_deserializacion.datos["registro"]
						)

						correctas = _comprobar(
								reconstruido.numero == movimiento.numero
								and reconstruido.origen_id == movimiento.origen_id
								and reconstruido.destino_id == movimiento.destino_id
								and reconstruido.es_primer_movimiento == movimiento.es_primer_movimiento,
                                "Conserva todos los campos del movimiento"
						) and correctas

		# 2. Serialización de un movimiento posterior válido.
		var posterior := TipoRegistroMovimiento.new()
		posterior.numero = 2
		posterior.origen_id = 13
		posterior.destino_id = 1
		posterior.es_primer_movimiento = false

		resultado_serializacion = TipoSerializador.serializar(posterior)

		correctas = _comprobar(
				resultado_serializacion.aceptado,
                "Serializa movimiento posterior valido"
		) and correctas

		# 3. Rechazos durante la serialización.
		correctas = _comprobar(
				not TipoSerializador.serializar(null).aceptado,
                "Rechaza registro nulo"
		) and correctas

		var incorrecto := TipoRegistroMovimiento.new()
		incorrecto.numero = 0
		incorrecto.origen_id = -1
		incorrecto.destino_id = 13
		incorrecto.es_primer_movimiento = true

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza numero de movimiento no valido"
		) and correctas

		incorrecto = _crear_primer_movimiento()
		incorrecto.destino_id = -1

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza destino negativo"
		) and correctas

		incorrecto = _crear_primer_movimiento()
		incorrecto.numero = 2

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza primer movimiento con numero incorrecto"
		) and correctas

		incorrecto = _crear_primer_movimiento()
		incorrecto.origen_id = 0

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza origen incorrecto del primer movimiento"
		) and correctas

		incorrecto = _crear_movimiento_posterior()
		incorrecto.numero = 1

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza movimiento posterior con numero 1"
		) and correctas

		incorrecto = _crear_movimiento_posterior()
		incorrecto.origen_id = -1

		correctas = _comprobar(
				not TipoSerializador.serializar(incorrecto).aceptado,
                "Rechaza origen negativo en movimiento posterior"
		) and correctas

		# 4. Rechazos durante la deserialización.
		var datos_base: Dictionary = {
				"version_formato": 2,
				"numero": 1,
				"origen_id": -1,
				"destino_id": 13,
				"es_primer_movimiento": true
		}

		correctas = _comprobar(
				not TipoSerializador.deserializar({}).aceptado,
                "Rechaza datos sin version de formato"
		) and correctas

		var datos := datos_base.duplicate(true)
		datos["version_formato"] = "2"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza version de formato con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["version_formato"] = 1

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza formato antiguo"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["version_formato"] = 3

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza formato futuro no compatible"
		) and correctas

		datos = datos_base.duplicate(true)
		datos.erase("numero")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza campo entero ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["numero"] = "1"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza campo entero con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos.erase("es_primer_movimiento")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza marcador de primer movimiento ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["es_primer_movimiento"] = 1

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza marcador de primer movimiento no booleano"
		) and correctas

		# 5. Rechazos de coherencia del registro deserializado.
		datos = datos_base.duplicate(true)
		datos["numero"] = 0

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza numero de movimiento no valido"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["destino_id"] = -1

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza destino negativo"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["numero"] = 2

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza primer movimiento con numero incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["origen_id"] = 0

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza origen incorrecto del primer movimiento"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["numero"] = 2
		datos["origen_id"] = 13
		datos["es_primer_movimiento"] = false

		datos["origen_id"] = -1

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza origen negativo en movimiento posterior"
		) and correctas

		if correctas:
				print("RESULTADO: CORRECTO")
		else:
				print("RESULTADO: ERROR")

		return correctas


static func _crear_primer_movimiento() -> TipoRegistroMovimiento:
		var movimiento := TipoRegistroMovimiento.new()
		movimiento.numero = 1
		movimiento.origen_id = -1
		movimiento.destino_id = 13
		movimiento.es_primer_movimiento = true
		return movimiento


static func _crear_movimiento_posterior() -> TipoRegistroMovimiento:
		var movimiento := TipoRegistroMovimiento.new()
		movimiento.numero = 2
		movimiento.origen_id = 13
		movimiento.destino_id = 1
		movimiento.es_primer_movimiento = false
		return movimiento


static func _comprobar(
		condicion: bool,
		descripcion: String
) -> bool:
		if condicion:
				print("[CORRECTO] ", descripcion)
				return true

		print("[ERROR] ", descripcion)
		return false
