
extends RefCounted

const TipoConfiguracionPartida = preload(
        "res://scripts/datos/modelos/configuracion_partida.gd"
)
const TipoSerializador = preload(
        "res://scripts/datos/serializadores/serializador_configuracion_partida.gd"
)


static func ejecutar() -> bool:
		print("")
		print("--- Prueba: SerializadorConfiguracionPartida ---")

		var configuracion := TipoConfiguracionPartida.new()

		configuracion.id_partida = "prueba_001"
		configuracion.tipo_partida = TipoConfiguracionPartida.TIPO_NORMAL

		configuracion.id_geometria = TipoConfiguracionPartida.GEOMETRIA_RECTANGULAR
		configuracion.version_geometria = TipoConfiguracionPartida.VERSION_GEOMETRIA_RECTANGULAR

		configuracion.id_reglas_movimiento = TipoConfiguracionPartida.REGLAS_RECTANGULAR_SALTOS_3_2
		configuracion.version_reglas_movimiento = TipoConfiguracionPartida.VERSION_REGLAS_RECTANGULAR_SALTOS_3_2

		configuracion.filas = 5
		configuracion.columnas = 5

		configuracion.inicio_permitido = [0, 12]
		configuracion.final_permitido = [24]

		configuracion.usar_cronometro = true
		configuracion.usar_pistas = false

		# Serializar en formato 3.
		var resultado_serializacion = TipoSerializador.serializar(
				configuracion
		)

		if not resultado_serializacion.aceptado:
				print("Codigo de error: ", resultado_serializacion.codigo)
				print("Datos devueltos: ", resultado_serializacion.datos)
				push_error("Fallo al serializar la configuracion.")
				return false

		var datos: Dictionary = resultado_serializacion.datos["datos"]

		if datos["version_formato"] != 3:
				push_error("La version del formato no es correcta.")
				return false

		# Comprobar los IDs serializados.
		if datos["inicio_permitido"] != [0, 12]:
				push_error("Los IDs de inicio no se han serializado correctamente.")
				return false

		if datos["final_permitido"] != [24]:
				push_error("Los IDs finales no se han serializado correctamente.")
				return false

		for id_casilla in datos["inicio_permitido"]:
				if not (id_casilla is int):
						push_error("Un ID de inicio no es un entero.")
						return false

		for id_casilla in datos["final_permitido"]:
				if not (id_casilla is int):
						push_error("Un ID final no es un entero.")
						return false

		# Deserializar formato 3.
		var resultado_deserializacion = TipoSerializador.deserializar(
				datos
		)

		if not resultado_deserializacion.aceptado:
				print("Codigo de error: ", resultado_deserializacion.codigo)
				print("Datos devueltos: ", resultado_deserializacion.datos)
				push_error("Fallo al deserializar la configuracion.")
				return false

		var reconstruida = resultado_deserializacion.datos["configuracion"]

		if reconstruida.id_partida != configuracion.id_partida:
				push_error("El identificador no coincide.")
				return false

		if reconstruida.tipo_partida != configuracion.tipo_partida:
				push_error("El tipo de partida no coincide.")
				return false

		if reconstruida.id_geometria != configuracion.id_geometria:
				push_error("El identificador de geometria no coincide.")
				return false

		if reconstruida.version_geometria != configuracion.version_geometria:
				push_error("La version de geometria no coincide.")
				return false

		if reconstruida.id_reglas_movimiento != configuracion.id_reglas_movimiento:
				push_error("El identificador de reglas no coincide.")
				return false

		if reconstruida.version_reglas_movimiento != configuracion.version_reglas_movimiento:
				push_error("La version de reglas no coincide.")
				return false

		if reconstruida.filas != configuracion.filas:
				push_error("El numero de filas no coincide.")
				return false

		if reconstruida.columnas != configuracion.columnas:
				push_error("El numero de columnas no coincide.")
				return false

		if reconstruida.inicio_permitido != configuracion.inicio_permitido:
				push_error("Las restricciones de inicio no coinciden.")
				return false

		if reconstruida.final_permitido != configuracion.final_permitido:
				push_error("Las restricciones finales no coinciden.")
				return false

		if reconstruida.usar_cronometro != configuracion.usar_cronometro:
				push_error("La configuracion del cronometro no coincide.")
				return false

		if reconstruida.usar_pistas != configuracion.usar_pistas:
				push_error("La configuracion de pistas no coincide.")
				return false

		# ---------------------------------------------------------
		# Migracion del formato 2 al formato 3.
		# ---------------------------------------------------------

		var datos_v2: Dictionary = datos.duplicate(true)
		datos_v2["version_formato"] = 2

		datos_v2["inicio_permitido"] = [
				{"x": 0, "y": 0},
				{"x": 2, "y": 2}
		]

		datos_v2["final_permitido"] = [
				{"x": 4, "y": 4}
		]

		var resultado_migracion = TipoSerializador.deserializar(
				datos_v2
		)

		if not resultado_migracion.aceptado:
			print("Codigo de error: ", resultado_migracion.codigo)
			print("Datos devueltos: ", resultado_migracion.datos)
			push_error("Fallo al migrar el formato 2.")
			return false

		var migrada = resultado_migracion.datos["configuracion"]

		if migrada.inicio_permitido != [0, 12]:
			push_error("La migracion de los IDs de inicio es incorrecta.")
			return false

		if migrada.final_permitido != [24]:
			push_error("La migracion de los IDs finales es incorrecta.")
			return false

		# Comprobar que la configuracion migrada se guarda en formato 3.
		var resultado_serializacion_migrada = TipoSerializador.serializar(
				migrada
		)

		if not resultado_serializacion_migrada.aceptado:
			push_error("No se pudo guardar la configuracion migrada.")
			return false

		var datos_migrados: Dictionary = resultado_serializacion_migrada.datos["datos"]

		if datos_migrados["version_formato"] != 3:
			push_error("La configuracion migrada no se guarda en formato 3.")
			return false

		# ---------------------------------------------------------
		# Rechazo de coordenadas antiguas fuera del tablero.
		# ---------------------------------------------------------

		var datos_v2_invalidos: Dictionary = datos_v2.duplicate(true)

		datos_v2_invalidos["inicio_permitido"] = [
				{"x": 5, "y": 0}
		]

		var resultado_v2_invalido = TipoSerializador.deserializar(
				datos_v2_invalidos
		)

		if resultado_v2_invalido.aceptado:
			push_error("Se ha aceptado una coordenada antigua fuera del tablero.")
			return false

		# ---------------------------------------------------------
		# Rechazo de IDs no enteros en formato 3.
		# ---------------------------------------------------------

		var datos_v3_invalidos: Dictionary = datos.duplicate(true)

		datos_v3_invalidos["inicio_permitido"] = [0, "12"]

		var resultado_v3_invalido = TipoSerializador.deserializar(
				datos_v3_invalidos
		)

		if resultado_v3_invalido.aceptado:
			push_error("Se ha aceptado un ID que no es entero.")
			return false

		# ---------------------------------------------------------
		# Rechazo de versiones no compatibles.
		# ---------------------------------------------------------

		var datos_futuros: Dictionary = datos.duplicate(true)
		datos_futuros["version_formato"] = 4

		var resultado_futuro = TipoSerializador.deserializar(
				datos_futuros
		)

		if resultado_futuro.aceptado:
			push_error("Se ha aceptado una version de formato futura.")
			return false

		var datos_antiguos: Dictionary = datos.duplicate(true)
		datos_antiguos["version_formato"] = 1

		var resultado_antiguo = TipoSerializador.deserializar(
				datos_antiguos
		)

		if resultado_antiguo.aceptado:
			push_error("Se ha aceptado una version de formato no soportada.")
			return false

		print("Comprobacion formato 3: CORRECTA")
		print("Comprobacion migracion formato 2: CORRECTA")
		print("Comprobacion datos invalidos: CORRECTA")
		print("Comprobacion versiones incompatibles: CORRECTA")
		print("RESULTADO: CORRECTO")

		return true
