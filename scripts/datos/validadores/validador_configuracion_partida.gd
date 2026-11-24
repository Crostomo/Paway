
class_name ValidadorConfiguracionPartida
extends RefCounted

const TipoConfiguracionPartida = preload(
        "res://scripts/datos/modelos/configuracion_partida.gd"
)
const TipoResultadoOperacion = preload(
        "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorDimensiones = preload(
        "res://scripts/datos/validadores/validador_dimensiones_tablero.gd"
)
const TipoGeometriaTablero = preload(
        "res://scripts/datos/modelos/geometria_tablero.gd"
)
const TipoReglasMovimiento = preload(
        "res://scripts/datos/modelos/reglas_movimiento.gd"
)


static func validar(
		configuracion: TipoConfiguracionPartida
) -> TipoResultadoOperacion:

		if configuracion == null:
				return _error("CONFIGURACION_NULA")

		# Comprobar la geometria.
		if configuracion.id_geometria != TipoGeometriaTablero.GEOMETRIA_RECTANGULAR:
				return _error("GEOMETRIA_NO_COMPATIBLE")

		if configuracion.version_geometria != TipoGeometriaTablero.VERSION_RECTANGULAR:
				return _error("VERSION_GEOMETRIA_NO_COMPATIBLE")

		# Comprobar las reglas de movimiento.
		if configuracion.id_reglas_movimiento != TipoReglasMovimiento.ID_REGLAS_RECTANGULAR:
				return _error("REGLAS_MOVIMIENTO_NO_COMPATIBLES")

		if configuracion.version_reglas_movimiento != TipoReglasMovimiento.VERSION_REGLAS_RECTANGULAR:
				return _error("VERSION_REGLAS_NO_COMPATIBLE")

		# Comprobar dimensiones.
		var resultado_dimensiones := TipoValidadorDimensiones.validar(
				configuracion.filas,
				configuracion.columnas
		)

		if not resultado_dimensiones.aceptado:
				return resultado_dimensiones

		# Construir la geometria del tablero.
		var geometria = TipoGeometriaTablero.new()

		if not geometria.configurar_rectangular(
				configuracion.filas,
				configuracion.columnas
		):
				return _error("GEOMETRIA_NO_VALIDA")

		# Comprobar tipo de partida.
		if not [
				TipoConfiguracionPartida.TIPO_NORMAL,
				TipoConfiguracionPartida.TIPO_PERSONALIZADA,
				TipoConfiguracionPartida.TIPO_RETO
		].has(configuracion.tipo_partida):
				return _error("TIPO_PARTIDA_NO_VALIDO")

		# Comprobar identificador del reto.
		if configuracion.tipo_partida == TipoConfiguracionPartida.TIPO_RETO:
				if configuracion.id_reto.strip_edges().is_empty():
						return _error("RETO_SIN_IDENTIFICADOR")
		elif not configuracion.id_reto.strip_edges().is_empty():
				return _error("IDENTIFICADOR_RETO_NO_CORRESPONDE")

		# Comprobar restricciones de inicio.
		var resultado_inicio := _validar_restricciones(
				configuracion.inicio_permitido,
				geometria,
                "INICIO"
		)

		if not resultado_inicio.aceptado:
				return resultado_inicio

		# Comprobar restricciones de final.
		var resultado_final := _validar_restricciones(
				configuracion.final_permitido,
				geometria,
                "FINAL"
		)

		if not resultado_final.aceptado:
				return resultado_final

		return TipoResultadoOperacion.crear_correcto(
				TipoResultadoOperacion.CODIGO_CORRECTO,
				{"total_casillas": geometria.obtener_total_casillas()}
		)


static func _validar_restricciones(
		casillas: Array[int],
		geometria,
		tipo: String
) -> TipoResultadoOperacion:

		var casillas_vistas: Dictionary = {}

		for id_casilla: int in casillas:

				# Comprobar que el ID pertenece al tablero.
				if not geometria.contiene_id_casilla(id_casilla):
						return _error(tipo + "_FUERA_TABLERO")

				# Comprobar que no hay IDs repetidos.
				if casillas_vistas.has(id_casilla):
						return _error(tipo + "_DUPLICADO")

				casillas_vistas[id_casilla] = true

		return TipoResultadoOperacion.crear_correcto(
				TipoResultadoOperacion.CODIGO_CORRECTO
		)


static func _error(motivo: String) -> TipoResultadoOperacion:
		return TipoResultadoOperacion.crear_error(
				TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
				{"motivo": motivo}
		)
