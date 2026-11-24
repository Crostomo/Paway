
extends RefCounted

const TipoDatosProgreso = preload(
	"res://scripts/datos/modelos/datos_progreso.gd"
)
const TipoValidador = preload(
	"res://scripts/datos/validadores/validador_datos_progreso.gd"
)


static func ejecutar() -> bool:
	print("")
	print("--- Validador de datos de progreso ---")

	var correctas: int = 0
	var total: int = 12

	if TipoValidador.validar(_crear_progreso()).aceptado:
		correctas += 1
		print("CORRECTO: progreso valido")
	else:
		print("ERROR: progreso valido")

	if not TipoValidador.validar(null).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de progreso nulo")
	else:
		print("ERROR: se ha aceptado progreso nulo")

	var version := _crear_progreso()
	version.version_formato = 2
	if not TipoValidador.validar(version).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de version incompatible")
	else:
		print("ERROR: version incompatible")

	var experiencia := _crear_progreso()
	experiencia.experiencia_total = -1
	if not TipoValidador.validar(experiencia).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de experiencia negativa")
	else:
		print("ERROR: experiencia negativa")

	var nivel := _crear_progreso()
	nivel.nivel_actual = 0
	if not TipoValidador.validar(nivel).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de nivel no valido")
	else:
		print("ERROR: nivel no valido")

	var recompensa_vacia := _crear_progreso()
	recompensa_vacia.recompensas_concedidas.append("")
	if not TipoValidador.validar(recompensa_vacia).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de recompensa vacia")
	else:
		print("ERROR: recompensa vacia")

	var recompensa_con_espacios := _crear_progreso()
	recompensa_con_espacios.recompensas_concedidas.append(" logro_1 ")
	if not TipoValidador.validar(recompensa_con_espacios).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de espacios en recompensa")
	else:
		print("ERROR: espacios en recompensa")

	var recompensa_duplicada := _crear_progreso()
	recompensa_duplicada.recompensas_concedidas.append("logro_1")
	recompensa_duplicada.recompensas_concedidas.append("logro_1")
	if not TipoValidador.validar(recompensa_duplicada).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de recompensa duplicada")
	else:
		print("ERROR: recompensa duplicada")

	var dimensiones_incorrectas := _crear_progreso()
	dimensiones_incorrectas.dimensiones_completadas.append("5-5")
	if not TipoValidador.validar(dimensiones_incorrectas).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de formato de dimensiones")
	else:
		print("ERROR: formato de dimensiones")

	var dimensiones_no_canonicas := _crear_progreso()
	dimensiones_no_canonicas.dimensiones_completadas.append("05x5")
	if not TipoValidador.validar(dimensiones_no_canonicas).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de dimensiones no canonicas")
	else:
		print("ERROR: dimensiones no canonicas")

	var dimensiones_pequenas := _crear_progreso()
	dimensiones_pequenas.dimensiones_completadas.append("4x5")
	if not TipoValidador.validar(dimensiones_pequenas).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de dimensiones inferiores al minimo")
	else:
		print("ERROR: dimensiones inferiores al minimo")

	var dimensiones_grandes := _crear_progreso()
	dimensiones_grandes.dimensiones_completadas.append("25x21")
	if not TipoValidador.validar(dimensiones_grandes).aceptado:
		correctas += 1
		print("CORRECTO: rechazo de mas de 500 casillas")
	else:
		print("ERROR: mas de 500 casillas")

	print("Resultado: ", correctas, "/", total)

	return correctas == total


static func _crear_progreso() -> TipoDatosProgreso:
	var progreso := TipoDatosProgreso.new()
	progreso.experiencia_total = 100
	progreso.nivel_actual = 2
	progreso.recompensas_concedidas.append("logro_inicial")
	progreso.dimensiones_completadas.append("5x5")
	return progreso
