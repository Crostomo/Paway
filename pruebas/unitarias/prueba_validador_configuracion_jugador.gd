
extends RefCounted

const TipoConfiguracionJugador = preload(
	"res://scripts/datos/modelos/configuracion_jugador.gd"
)
const TipoValidador = preload(
	"res://scripts/datos/validadores/validador_configuracion_jugador.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Validador de configuracion de jugador ---")

	var correctas: int = 0
	var total: int = 15

	if TipoValidador.validar(_crear_configuracion()).aceptado:
		correctas += 1
		print("CORRECTO: configuracion valida")
	else:
		print("ERROR: configuracion valida")

	if not TipoValidador.validar(null).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de configuracion nula")
	else:
		print("ERROR: configuracion nula")

	var version := _crear_configuracion()
	version.version_formato = 2
	if not TipoValidador.validar(version).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de version incompatible")
	else:
		print("ERROR: version incompatible")

	var tema := _crear_configuracion()
	tema.tema = "rojo"
	if not TipoValidador.validar(tema).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de tema no admitido")
	else:
		print("ERROR: tema no admitido")

	var estilo := _crear_configuracion()
	estilo.estilo_visual = "futurista"
	if not TipoValidador.validar(estilo).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de estilo no admitido")
	else:
		print("ERROR: estilo no admitido")

	var idioma := _crear_configuracion()
	idioma.idioma = "de"
	if not TipoValidador.validar(idioma).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de idioma no admitido")
	else:
		print("ERROR: idioma no admitido")

	var texto_inferior := _crear_configuracion()
	texto_inferior.escala_texto = 0.75
	if TipoValidador.validar(texto_inferior).aceptado:
		correctas += 1
		print("CORRECTO: limite inferior de escala de texto")
	else:
		print("ERROR: limite inferior de escala de texto")

	var texto_superior := _crear_configuracion()
	texto_superior.escala_texto = 2.0
	if TipoValidador.validar(texto_superior).aceptado:
		correctas += 1
		print("CORRECTO: limite superior de escala de texto")
	else:
		print("ERROR: limite superior de escala de texto")

	var texto_bajo := _crear_configuracion()
	texto_bajo.escala_texto = 0.74
	if not TipoValidador.validar(texto_bajo).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de escala de texto inferior")
	else:
		print("ERROR: escala de texto inferior")

	var texto_alto := _crear_configuracion()
	texto_alto.escala_texto = 2.01
	if not TipoValidador.validar(texto_alto).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de escala de texto superior")
	else:
		print("ERROR: escala de texto superior")

	var numeros_bajos := _crear_configuracion()
	numeros_bajos.tamano_numeros = 0.74
	if not TipoValidador.validar(numeros_bajos).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de tamano de numeros inferior")
	else:
		print("ERROR: tamano de numeros inferior")

	var numeros_altos := _crear_configuracion()
	numeros_altos.tamano_numeros = 2.01
	if not TipoValidador.validar(numeros_altos).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de tamano de numeros superior")
	else:
		print("ERROR: tamano de numeros superior")

	var tipografia_vacia := _crear_configuracion()
	tipografia_vacia.tipografia = ""
	if not TipoValidador.validar(tipografia_vacia).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de tipografia vacia")
	else:
		print("ERROR: tipografia vacia")

	var tipografia_espacios := _crear_configuracion()
	tipografia_espacios.tipografia = "   "
	if not TipoValidador.validar(tipografia_espacios).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de tipografia con espacios")
	else:
		print("ERROR: tipografia con espacios")

	var tipografia_bordes := _crear_configuracion()
	tipografia_bordes.tipografia = " Roboto "
	if not TipoValidador.validar(tipografia_bordes).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de espacios en tipografia")
	else:
		print("ERROR: espacios en tipografia")

	print("Resultado: ", correctas, "/", total)

	return correctas == total


static func _crear_configuracion() -> TipoConfiguracionJugador:
	var configuracion := TipoConfiguracionJugador.new()
	configuracion.tema = "sistema"
	configuracion.estilo_visual = "clasico"
	configuracion.idioma = "automatico"
	configuracion.tipografia = "Roboto"
	configuracion.escala_texto = 1.0
	configuracion.tamano_numeros = 1.0
	return configuracion
