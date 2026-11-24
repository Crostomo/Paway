
extends RefCounted

const TipoConfiguracionJugador = preload(
    "res://scripts/datos/modelos/configuracion_jugador.gd"
)
const TipoSerializador = preload(
    "res://scripts/datos/serializadores/serializador_configuracion_jugador.gd"
)


static func ejecutar() -> bool:
    print("")
    print("--- Prueba: SerializadorConfiguracionJugador ---")

    var configuracion = TipoConfiguracionJugador.new()

    configuracion.version_formato = 1
    configuracion.tema = "oscuro"
    configuracion.estilo_visual = "moderno"
    configuracion.idioma = "es"
    configuracion.tipografia = "predeterminada"
    configuracion.escala_texto = 1.25
    configuracion.contraste_alto = true
    configuracion.mostrar_movimientos_validos = true
    configuracion.mostrar_casillas_utilizadas = true
    configuracion.tamano_numeros = 1.25
    configuracion.reducir_animaciones = true
    configuracion.usar_vibracion = false
    configuracion.usar_sonidos = true
    configuracion.usar_lector_pantalla = true
    configuracion.usar_cronometro_por_defecto = true
    configuracion.usar_pistas_por_defecto = false
    configuracion.confirmar_abandono = true
    configuracion.confirmar_reinicio = true
    configuracion.ultima_actualizacion = "2026-11-23T12:00:00"

    var resultado_serializacion = TipoSerializador.serializar(
        configuracion
    )

    if resultado_serializacion == null:
        push_error("La serializacion ha devuelto null.")
        return false

    if not resultado_serializacion.aceptado:
        print("Error de serializacion: ", resultado_serializacion.datos)
        push_error("Fallo al serializar la configuracion.")
        return false

    var resultado_deserializacion = TipoSerializador.deserializar(
        resultado_serializacion.datos["datos"]
    )

    if resultado_deserializacion == null:
        push_error("La deserializacion ha devuelto null.")
        return false

    if not resultado_deserializacion.aceptado:
        print("Error de deserializacion: ", resultado_deserializacion.datos)
        push_error("Fallo al deserializar la configuracion.")
        return false

    var reconstruida = resultado_deserializacion.datos["configuracion"]

    if reconstruida.version_formato != configuracion.version_formato:
        push_error("La version del formato no coincide.")
        return false

    if reconstruida.tema != configuracion.tema:
        push_error("El tema no coincide.")
        return false

    if reconstruida.estilo_visual != configuracion.estilo_visual:
        push_error("El estilo visual no coincide.")
        return false

    if reconstruida.idioma != configuracion.idioma:
        push_error("El idioma no coincide.")
        return false

    if reconstruida.tipografia != configuracion.tipografia:
        push_error("La tipografia no coincide.")
        return false

    if reconstruida.escala_texto != configuracion.escala_texto:
        push_error("La escala de texto no coincide.")
        return false

    if reconstruida.contraste_alto != configuracion.contraste_alto:
        push_error("La configuracion de contraste no coincide.")
        return false

    if reconstruida.mostrar_movimientos_validos != configuracion.mostrar_movimientos_validos:
        push_error("La preferencia de movimientos validos no coincide.")
        return false

    if reconstruida.mostrar_casillas_utilizadas != configuracion.mostrar_casillas_utilizadas:
        push_error("La preferencia de casillas utilizadas no coincide.")
        return false

    if reconstruida.tamano_numeros != configuracion.tamano_numeros:
        push_error("El tamano de numeros no coincide.")
        return false

    if reconstruida.reducir_animaciones != configuracion.reducir_animaciones:
        push_error("La preferencia de animaciones no coincide.")
        return false

    if reconstruida.usar_vibracion != configuracion.usar_vibracion:
        push_error("La preferencia de vibracion no coincide.")
        return false

    if reconstruida.usar_sonidos != configuracion.usar_sonidos:
        push_error("La preferencia de sonidos no coincide.")
        return false

    if reconstruida.usar_lector_pantalla != configuracion.usar_lector_pantalla:
        push_error("La preferencia del lector de pantalla no coincide.")
        return false

    if reconstruida.usar_cronometro_por_defecto != configuracion.usar_cronometro_por_defecto:
        push_error("La preferencia del cronometro no coincide.")
        return false

    if reconstruida.usar_pistas_por_defecto != configuracion.usar_pistas_por_defecto:
        push_error("La preferencia de pistas no coincide.")
        return false

    if reconstruida.confirmar_abandono != configuracion.confirmar_abandono:
        push_error("La preferencia de confirmacion de abandono no coincide.")
        return false

    if reconstruida.confirmar_reinicio != configuracion.confirmar_reinicio:
        push_error("La preferencia de confirmacion de reinicio no coincide.")
        return false

    if reconstruida.ultima_actualizacion != configuracion.ultima_actualizacion:
        push_error("La fecha de actualizacion no coincide.")
        return false

    print("RESULTADO: CORRECTO")
    return true
