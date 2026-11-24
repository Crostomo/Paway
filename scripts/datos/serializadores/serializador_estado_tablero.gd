
class_name SerializadorEstadoTablero
extends RefCounted

const VERSION_FORMATO: int = 2

const GEOMETRIA_RECTANGULAR: String = "rectangular"
const VERSION_GEOMETRIA_RECTANGULAR: int = 1

const REGLAS_RECTANGULAR_SALTOS_3_2: String = (
	"rectangular_saltos_3_2"
)
const VERSION_REGLAS_RECTANGULAR_SALTOS_3_2: int = 1

const TipoEstadoTablero = preload(
	"res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistroMovimiento = preload(
	"res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoResultadoOperacion = preload(
	"res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoSerializadorMovimiento = preload(
	"res://scripts/datos/serializadores/serializador_registro_movimiento.gd"
)
const TipoValidadorEstado = preload(
	"res://scripts/datos/validadores/validador_estado_tablero.gd"
)


static func serializar(
	estado: TipoEstadoTablero
) -> TipoResultadoOperacion:

	var resultado_validacion := TipoValidadorEstado.validar(estado)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	var matriz_datos: Array = []

	for fila in estado.matriz:
		matriz_datos.append(fila.duplicate(true))

	var historial_datos: Array[Dictionary] = []

	for registro in estado.historial:
		var resultado_movimiento := TipoSerializadorMovimiento.serializar(
			registro
		)

		if not resultado_movimiento.aceptado:
			return resultado_movimiento

		historial_datos.append(resultado_movimiento.datos["datos"])

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"id_geometria": estado.id_geometria,
		"version_geometria": estado.version_geometria,
		"id_reglas_movimiento": estado.id_reglas_movimiento,
		"version_reglas_movimiento": estado.version_reglas_movimiento,
		"filas": estado.filas,
		"columnas": estado.columnas,
		"matriz": matriz_datos,
		"historial": historial_datos,
		"ultima_casilla_id": estado.ultima_casilla_id,
		"estado": estado.estado,
		"movimientos_realizados": estado.movimientos_realizados,
		"movimientos_deshechos": estado.movimientos_deshechos,
		"movimientos_efectivos": estado.movimientos_efectivos
	}

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"datos": datos}
	)


static func deserializar(
	datos: Dictionary
) -> TipoResultadoOperacion:

	if not datos.has("version_formato"):
		return _error("FALTA_VERSION_FORMATO")

	if not (datos["version_formato"] is int):
		return _error("VERSION_FORMATO_NO_VALIDA")

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var campos_texto: Array[String] = [
		"id_geometria",
		"id_reglas_movimiento",
		"estado"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO: " + campo)

	var campos_enteros: Array[String] = [
		"version_geometria",
		"version_reglas_movimiento",
		"filas",
		"columnas",
		"ultima_casilla_id",
		"movimientos_realizados",
		"movimientos_deshechos",
		"movimientos_efectivos"
	]

	for campo in campos_enteros:
		if not datos.has(campo) or not (datos[campo] is int):
			return _error("CAMPO_ENTERO_NO_VALIDO: " + campo)

	if not datos.has("matriz") or not (datos["matriz"] is Array):
		return _error("MATRIZ_NO_VALIDA")

	if not datos.has("historial") or not (datos["historial"] is Array):
		return _error("HISTORIAL_NO_VALIDO")

	var matriz: Array[Array] = []

	for fila_datos in datos["matriz"]:
		if not (fila_datos is Array):
			return _error("FILA_MATRIZ_NO_VALIDA")

		var fila: Array = []

		for valor in fila_datos:
			if not (valor is int):
				return _error("VALOR_MATRIZ_NO_VALIDO")

			fila.append(valor)

		matriz.append(fila)

	var historial: Array[TipoRegistroMovimiento] = []

	for movimiento_datos in datos["historial"]:
		if not (movimiento_datos is Dictionary):
			return _error("REGISTRO_HISTORIAL_NO_VALIDO")

		var resultado_movimiento := TipoSerializadorMovimiento.deserializar(
			movimiento_datos
		)

		if not resultado_movimiento.aceptado:
			return resultado_movimiento

		var registro: TipoRegistroMovimiento = (
			resultado_movimiento.datos["registro"]
		)

		historial.append(registro)

	var estado := TipoEstadoTablero.new()

	estado.id_geometria = datos["id_geometria"]
	estado.version_geometria = datos["version_geometria"]
	estado.id_reglas_movimiento = datos["id_reglas_movimiento"]
	estado.version_reglas_movimiento = datos["version_reglas_movimiento"]

	estado.filas = datos["filas"]
	estado.columnas = datos["columnas"]
	estado.matriz = matriz
	estado.historial = historial
	estado.ultima_casilla_id = datos["ultima_casilla_id"]
	estado.estado = datos["estado"]

	estado.movimientos_realizados = datos["movimientos_realizados"]
	estado.movimientos_deshechos = datos["movimientos_deshechos"]
	estado.movimientos_efectivos = datos["movimientos_efectivos"]

	var resultado_validacion := TipoValidadorEstado.validar(estado)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"estado_tablero": estado}
	)


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
