
extends RefCounted

const TipoEstadoTablero = preload(
        "res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistroMovimiento = preload(
        "res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoSerializador = preload(
        "res://scripts/datos/serializadores/serializador_estado_tablero.gd"
)


static func ejecutar() -> bool:
		print("")
		print("--- Prueba: SerializadorEstadoTablero ---")

		var correctas: bool = true
		var estado := _crear_estado_valido()

		# 1. Serializacion del estado valido.
		var resultado_serializacion := TipoSerializador.serializar(estado)

		correctas = _comprobar(
				resultado_serializacion.aceptado,
                "Serializa tablero valido"
		) and correctas

		if resultado_serializacion.aceptado:
				var datos_serializados: Dictionary = (
						resultado_serializacion.datos["datos"]
				)

				correctas = _comprobar(
						datos_serializados["version_formato"] == 2,
                        "Utiliza formato 2"
				) and correctas

				correctas = _comprobar(
						datos_serializados["ultima_casilla_id"] == 22,
                        "Conserva la ultima casilla"
				) and correctas

				# 2. Deserializacion y comprobacion del roundtrip.
				var resultado_deserializacion := (
						TipoSerializador.deserializar(datos_serializados)
				)

				correctas = _comprobar(
						resultado_deserializacion.aceptado,
                        "Deserializa tablero valido"
				) and correctas

				if resultado_deserializacion.aceptado:
						var reconstruido = (
								resultado_deserializacion.datos["estado_tablero"]
						)

						correctas = _comprobar(
								_comparar_estados(estado, reconstruido),
                                "Conserva todos los datos del tablero"
						) and correctas

		# 3. Rechazo de estados invalidos durante la serializacion.
		var estado_incorrecto := _crear_estado_valido()
		estado_incorrecto.movimientos_efectivos = 2

		correctas = _comprobar(
				not TipoSerializador.serializar(estado_incorrecto).aceptado,
                "Rechaza estado con contadores incoherentes"
		) and correctas

		estado_incorrecto = _crear_estado_valido()
		estado_incorrecto.matriz[2][3] = 0

		correctas = _comprobar(
				not TipoSerializador.serializar(estado_incorrecto).aceptado,
                "Rechaza matriz que no coincide con el historial"
		) and correctas

		# 4. Preparacion de datos validos para las pruebas negativas.
		var datos_base: Dictionary = (
				TipoSerializador.serializar(_crear_estado_valido()).datos["datos"]
		)

		# 5. Version del formato.
		var datos := datos_base.duplicate(true)
		datos.erase("version_formato")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza datos sin version de formato"
		) and correctas

		datos = datos_base.duplicate(true)
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

		# 6. Campos de texto.
		datos = datos_base.duplicate(true)
		datos.erase("id_geometria")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza identidad de geometria ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["id_reglas_movimiento"] = 123

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza identidad de reglas con tipo incorrecto"
		) and correctas

		# 7. Campos enteros.
		datos = datos_base.duplicate(true)
		datos.erase("filas")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza campo entero ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["columnas"] = "5"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza campo entero con tipo incorrecto"
		) and correctas

		# 8. Matriz.
		datos = datos_base.duplicate(true)
		datos.erase("matriz")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza matriz ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["matriz"] = "matriz"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza matriz con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["matriz"][0] = "fila"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza fila de matriz con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["matriz"] = [["texto"]]

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza valor de matriz con tipo incorrecto"
		) and correctas

		# 9. Historial.
		datos = datos_base.duplicate(true)
		datos.erase("historial")

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza historial ausente"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["historial"] = "historial"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza historial con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["historial"] = ["movimiento"]

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza registro de historial con tipo incorrecto"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["historial"][0]["destino_id"] = -1

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza movimiento interno incoherente"
		) and correctas

		# 10. Coherencia del estado reconstruido.
		datos = datos_base.duplicate(true)
		datos["filas"] = 0

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza dimensiones no validas"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["id_geometria"] = "geometria_desconocida"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza geometria incompatible"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["version_geometria"] = 99

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza version de geometria incompatible"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["id_reglas_movimiento"] = "reglas_desconocidas"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza reglas de movimiento incompatibles"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["version_reglas_movimiento"] = 99

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza version de reglas incompatible"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["movimientos_efectivos"] = 2

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza contadores incoherentes"
		) and correctas

		datos = datos_base.duplicate(true)
		datos["estado"] = "estado_desconocido"

		correctas = _comprobar(
				not TipoSerializador.deserializar(datos).aceptado,
                "Rechaza estado del tablero desconocido"
		) and correctas

		if correctas:
				print("RESULTADO: CORRECTO")
		else:
				print("RESULTADO: ERROR")

		return correctas


static func _crear_estado_valido() -> TipoEstadoTablero:
		var estado := TipoEstadoTablero.new()

		estado.filas = 5
		estado.columnas = 5
		estado.matriz.clear()

		for fila in range(estado.filas):
				var nueva_fila: Array[int] = []

				for columna in range(estado.columnas):
						nueva_fila.append(0)

				estado.matriz.append(nueva_fila)

		estado.matriz[2][3] = 1
		estado.matriz[2][0] = 2
		estado.matriz[4][2] = 3

		var primero := TipoRegistroMovimiento.new()
		primero.numero = 1
		primero.origen_id = -1
		primero.destino_id = 13
		primero.es_primer_movimiento = true
		estado.historial.append(primero)

		var segundo := TipoRegistroMovimiento.new()
		segundo.numero = 2
		segundo.origen_id = 13
		segundo.destino_id = 10
		segundo.es_primer_movimiento = false
		estado.historial.append(segundo)

		var tercero := TipoRegistroMovimiento.new()
		tercero.numero = 3
		tercero.origen_id = 10
		tercero.destino_id = 22
		tercero.es_primer_movimiento = false
		estado.historial.append(tercero)

		estado.ultima_casilla_id = 22
		estado.estado = TipoEstadoTablero.ESTADO_ACTIVA
		estado.movimientos_realizados = 3
		estado.movimientos_deshechos = 0
		estado.movimientos_efectivos = 3

		return estado


static func _comparar_estados(
		original: TipoEstadoTablero,
		reconstruido: TipoEstadoTablero
) -> bool:
		if reconstruido.id_geometria != original.id_geometria:
				return false

		if reconstruido.version_geometria != original.version_geometria:
				return false

		if reconstruido.id_reglas_movimiento != original.id_reglas_movimiento:
				return false

		if reconstruido.version_reglas_movimiento != original.version_reglas_movimiento:
				return false

		if reconstruido.filas != original.filas:
				return false

		if reconstruido.columnas != original.columnas:
				return false

		if reconstruido.matriz != original.matriz:
				return false

		if reconstruido.historial.size() != original.historial.size():
				return false

		if reconstruido.ultima_casilla_id != original.ultima_casilla_id:
				return false

		if reconstruido.estado != original.estado:
				return false

		if reconstruido.movimientos_realizados != original.movimientos_realizados:
				return false

		if reconstruido.movimientos_deshechos != original.movimientos_deshechos:
				return false

		if reconstruido.movimientos_efectivos != original.movimientos_efectivos:
				return false

		for indice in range(original.historial.size()):
				var movimiento_original = original.historial[indice]
				var movimiento_copia = reconstruido.historial[indice]

				if movimiento_original.numero != movimiento_copia.numero:
						return false

				if movimiento_original.origen_id != movimiento_copia.origen_id:
						return false

				if movimiento_original.destino_id != movimiento_copia.destino_id:
						return false

				if movimiento_original.es_primer_movimiento != movimiento_copia.es_primer_movimiento:
						return false

		return true


static func _comprobar(
		condicion: bool,
		descripcion: String
) -> bool:
		if condicion:
				print("[CORRECTO] ", descripcion)
				return true

		print("[ERROR] ", descripcion)
		return false
