
class_name ValidadorEstadoTablero
extends RefCounted

const MINIMO_CASILLAS_POR_LADO: int = 5
const MAXIMO_TOTAL_CASILLAS: int = 500

const TipoEstadoTablero = preload(
	"res://scripts/datos/modelos/estado_tablero.gd"
)
const TipoRegistroMovimiento = preload(
	"res://scripts/datos/modelos/registro_movimiento.gd"
)
const TipoResultadoOperacion = preload(
	"res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoGeometriaTablero = preload(
	"res://scripts/datos/modelos/geometria_tablero.gd"
)
const TipoReglasMovimiento = preload(
	"res://scripts/datos/modelos/reglas_movimiento.gd"
)


static func validar(
	estado: TipoEstadoTablero
) -> TipoResultadoOperacion:

	if estado == null:
		return _error("ESTADO_NULO")

	if estado.id_geometria != TipoGeometriaTablero.GEOMETRIA_RECTANGULAR:
		return _error("GEOMETRIA_NO_COMPATIBLE")

	if estado.version_geometria != TipoGeometriaTablero.VERSION_RECTANGULAR:
		return _error("VERSION_GEOMETRIA_NO_COMPATIBLE")

	if estado.id_reglas_movimiento != TipoReglasMovimiento.ID_REGLAS_RECTANGULAR:
		return _error("REGLAS_MOVIMIENTO_NO_COMPATIBLES")

	if estado.version_reglas_movimiento != TipoReglasMovimiento.VERSION_REGLAS_RECTANGULAR:
		return _error("VERSION_REGLAS_NO_COMPATIBLE")

	if estado.filas < MINIMO_CASILLAS_POR_LADO:
		return _error("NUMERO_FILAS_NO_VALIDO")

	if estado.columnas < MINIMO_CASILLAS_POR_LADO:
		return _error("NUMERO_COLUMNAS_NO_VALIDO")

	var total_casillas: int = estado.filas * estado.columnas

	if total_casillas > MAXIMO_TOTAL_CASILLAS:
		return _error("DEMASIADAS_CASILLAS")

	if estado.matriz.size() != estado.filas:
		return _error("NUMERO_FILAS_MATRIZ_INCORRECTO")

	var geometria := TipoGeometriaTablero.new()

	if not geometria.configurar_rectangular(
		estado.filas,
		estado.columnas
	):
		return _error("GEOMETRIA_NO_VALIDA")

	var numeros_vistos: Dictionary = {}
	var total_numeros: int = 0

	for fila in range(estado.filas):
		var datos_fila: Array = estado.matriz[fila]

		if datos_fila.size() != estado.columnas:
			return _error("NUMERO_COLUMNAS_MATRIZ_INCORRECTO")

		for columna in range(estado.columnas):
			var valor: Variant = datos_fila[columna]

			if not (valor is int):
				return _error("VALOR_MATRIZ_NO_VALIDO")

			if valor < 0 or valor > total_casillas:
				return _error("NUMERO_CASILLA_NO_VALIDO")

			if valor > 0:
				if numeros_vistos.has(valor):
					return _error("NUMERO_CASILLA_DUPLICADO")

				numeros_vistos[valor] = true
				total_numeros += 1

	if total_numeros != estado.historial.size():
		return _error("HISTORIAL_NO_COINCIDE_CON_MATRIZ")

	if estado.movimientos_realizados < 0:
		return _error("MOVIMIENTOS_REALIZADOS_NO_VALIDOS")

	if estado.movimientos_deshechos < 0:
		return _error("MOVIMIENTOS_DESHECHOS_NO_VALIDOS")

	if estado.movimientos_efectivos < 0:
		return _error("MOVIMIENTOS_EFECTIVOS_NO_VALIDOS")

	if estado.movimientos_deshechos > estado.movimientos_realizados:
		return _error("CONTADORES_MOVIMIENTOS_INCOHERENTES")

	if estado.movimientos_efectivos != (
		estado.movimientos_realizados - estado.movimientos_deshechos
	):
		return _error("CONTADORES_MOVIMIENTOS_INCOHERENTES")

	if estado.movimientos_efectivos != estado.historial.size():
		return _error("CONTADOR_EFECTIVO_NO_COINCIDE_CON_HISTORIAL")

	for numero in range(1, total_numeros + 1):
		if not numeros_vistos.has(numero):
			return _error("SECUENCIA_NUMERICA_INCOMPLETA")

	var reglas := TipoReglasMovimiento.new()
	var ultima_casilla_esperada: int = -1

	for indice in range(estado.historial.size()):
		var registro: Variant = estado.historial[indice]

		if not (registro is TipoRegistroMovimiento):
			return _error("REGISTRO_MOVIMIENTO_NO_VALIDO")

		if registro.numero != indice + 1:
			return _error("SECUENCIA_HISTORIAL_INCORRECTA")

		if not geometria.contiene_id_casilla(registro.destino_id):
			return _error("DESTINO_HISTORIAL_NO_VALIDO")

		if indice == 0:
			if not registro.es_primer_movimiento:
				return _error("PRIMER_MOVIMIENTO_NO_IDENTIFICADO")

			if registro.origen_id != -1:
				return _error("ORIGEN_PRIMER_MOVIMIENTO_INCORRECTO")
		else:
			if registro.es_primer_movimiento:
				return _error("PRIMER_MOVIMIENTO_DUPLICADO")

			if registro.origen_id != ultima_casilla_esperada:
				return _error("ORIGEN_HISTORIAL_INCORRECTO")

			if not reglas.es_movimiento_valido(
				geometria,
				registro.origen_id,
				registro.destino_id
			):
				return _error("DESPLAZAMIENTO_NO_PERMITIDO")

		var coordenadas: Vector2i = (
			geometria.obtener_coordenadas_casilla(
				registro.destino_id
			)
		)

		if estado.matriz[coordenadas.y][coordenadas.x] != registro.numero:
			return _error("DESTINO_HISTORIAL_NO_COINCIDE_CON_MATRIZ")

		ultima_casilla_esperada = registro.destino_id

	if estado.ultima_casilla_id != ultima_casilla_esperada:
		return _error("ULTIMA_CASILLA_INCORRECTA")

	if not _estado_es_valido(
		estado,
		total_casillas
	):
		return _error("ESTADO_TABLERO_INCOHERENTE")

	if estado.estado == TipoEstadoTablero.ESTADO_BLOQUEADA:
		if estado.historial.is_empty():
			return _error("TABLERO_BLOQUEADO_SIN_MOVIMIENTOS")

		var destinos: Array[int] = reglas.obtener_destinos_validos(
			geometria,
			estado.ultima_casilla_id
		)

		for destino_id in destinos:
			var coordenadas_destino: Vector2i = (
				geometria.obtener_coordenadas_casilla(destino_id)
			)

			if estado.matriz[coordenadas_destino.y][coordenadas_destino.x] == 0:
				return _error("TABLERO_BLOQUEADO_CON_MOVIMIENTOS_VALIDOS")

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO
	)


static func _estado_es_valido(
	estado: TipoEstadoTablero,
	total_casillas: int
) -> bool:

	match estado.estado:
		TipoEstadoTablero.ESTADO_PREPARADA:
			return estado.historial.is_empty()

		TipoEstadoTablero.ESTADO_ACTIVA:
			return (
				not estado.historial.is_empty()
				and estado.historial.size() < total_casillas
			)

		TipoEstadoTablero.ESTADO_BLOQUEADA:
			return estado.historial.size() < total_casillas

		TipoEstadoTablero.ESTADO_COMPLETADA:
			return estado.historial.size() == total_casillas

		_:
			return false


static func _error(motivo: String) -> TipoResultadoOperacion:
	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		{"motivo": motivo}
	)
