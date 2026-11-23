
class_name SerializadorConfiguracionJugador
extends RefCounted

const VERSION_FORMATO: int = 1

const TipoConfiguracionJugador = preload(
    "res://scripts/datos/modelos/configuracion_jugador.gd"
)
const TipoResultadoOperacion = preload(
    "res://scripts/datos/modelos/resultado_operacion.gd"
)
const TipoValidadorConfiguracion = preload(
    "res://scripts/datos/validadores/validador_configuracion_jugador.gd"
)


static func serializar(
	configuracion: TipoConfiguracionJugador
) -> TipoResultadoOperacion:

	var resultado_validacion := TipoValidadorConfiguracion.validar(
		configuracion
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	var datos: Dictionary = {
		"version_formato": VERSION_FORMATO,
		"tema": configuracion.tema,
		"estilo_visual": configuracion.estilo_visual,
		"idioma": configuracion.idioma,
		"tipografia": configuracion.tipografia,
		"escala_texto": configuracion.escala_texto,
		"contraste_alto": configuracion.contraste_alto,
		"mostrar_movimientos_validos": configuracion.mostrar_movimientos_validos,
		"mostrar_casillas_utilizadas": configuracion.mostrar_casillas_utilizadas,
		"tamano_numeros": configuracion.tamano_numeros,
		"reducir_animaciones": configuracion.reducir_animaciones,
		"usar_vibracion": configuracion.usar_vibracion,
		"usar_sonidos": configuracion.usar_sonidos,
		"usar_lector_pantalla": configuracion.usar_lector_pantalla,
		"usar_cronometro_por_defecto": configuracion.usar_cronometro_por_defecto,
		"usar_pistas_por_defecto": configuracion.usar_pistas_por_defecto,
		"confirmar_abandono": configuracion.confirmar_abandono,
		"confirmar_reinicio": configuracion.confirmar_reinicio,
		"ultima_actualizacion": configuracion.ultima_actualizacion
	}

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"datos": datos}
	)


static func deserializar(datos: Dictionary) -> TipoResultadoOperacion:

	if not datos.has("version_formato"):
		return _error("FALTA_VERSION_FORMATO")

	if not (datos["version_formato"] is int):
		return _error("VERSION_FORMATO_NO_VALIDA")

	if datos["version_formato"] != VERSION_FORMATO:
		return _error("VERSION_FORMATO_NO_COMPATIBLE")

	var campos_texto: Array[String] = [
		"tema",
		"estilo_visual",
		"idioma",
		"tipografia",
        "ultima_actualizacion"
	]

	var campos_booleanos: Array[String] = [
		"contraste_alto",
		"mostrar_movimientos_validos",
		"mostrar_casillas_utilizadas",
		"reducir_animaciones",
		"usar_vibracion",
		"usar_sonidos",
		"usar_lector_pantalla",
		"usar_cronometro_por_defecto",
		"usar_pistas_por_defecto",
		"confirmar_abandono",
        "confirmar_reinicio"
	]

	for campo in campos_texto:
		if not datos.has(campo) or not (datos[campo] is String):
			return _error("CAMPO_TEXTO_NO_VALIDO", {"campo": campo})

	for campo in campos_booleanos:
		if not datos.has(campo) or not (datos[campo] is bool):
			return _error("CAMPO_BOOLEANO_NO_VALIDO", {"campo": campo})

	if not datos.has("escala_texto") or not _es_numero(datos["escala_texto"]):
		return _error("ESCALA_TEXTO_NO_VALIDA")

	if not datos.has("tamano_numeros") or not _es_numero(datos["tamano_numeros"]):
		return _error("TAMANO_NUMEROS_NO_VALIDO")

	var configuracion := TipoConfiguracionJugador.new()

	configuracion.version_formato = VERSION_FORMATO
	configuracion.tema = datos["tema"]
	configuracion.estilo_visual = datos["estilo_visual"]
	configuracion.idioma = datos["idioma"]
	configuracion.tipografia = datos["tipografia"]
	configuracion.escala_texto = float(datos["escala_texto"])
	configuracion.contraste_alto = datos["contraste_alto"]
	configuracion.mostrar_movimientos_validos = datos["mostrar_movimientos_validos"]
	configuracion.mostrar_casillas_utilizadas = datos["mostrar_casillas_utilizadas"]
	configuracion.tamano_numeros = float(datos["tamano_numeros"])
	configuracion.reducir_animaciones = datos["reducir_animaciones"]
	configuracion.usar_vibracion = datos["usar_vibracion"]
	configuracion.usar_sonidos = datos["usar_sonidos"]
	configuracion.usar_lector_pantalla = datos["usar_lector_pantalla"]
	configuracion.usar_cronometro_por_defecto = datos["usar_cronometro_por_defecto"]
	configuracion.usar_pistas_por_defecto = datos["usar_pistas_por_defecto"]
	configuracion.confirmar_abandono = datos["confirmar_abandono"]
	configuracion.confirmar_reinicio = datos["confirmar_reinicio"]
	configuracion.ultima_actualizacion = datos["ultima_actualizacion"]

	var resultado_validacion := TipoValidadorConfiguracion.validar(
		configuracion
	)

	if not resultado_validacion.aceptado:
		return resultado_validacion

	return TipoResultadoOperacion.crear_correcto(
		TipoResultadoOperacion.CODIGO_CORRECTO,
		{"configuracion": configuracion}
	)


static func _es_numero(valor: Variant) -> bool:
	return valor is int or valor is float


static func _error(
	motivo: String,
	detalles: Dictionary = {}
) -> TipoResultadoOperacion:

	var datos_error: Dictionary = {"motivo": motivo}
	datos_error.merge(detalles)

	return TipoResultadoOperacion.crear_error(
		TipoResultadoOperacion.CODIGO_DATOS_INVALIDOS,
		datos_error
	)
