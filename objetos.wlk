import personajes.*
import niveles.*
class Bloqueador {
    var property image = "transparente.png"
    var property position = game.origin()
}

class Portal {
    var property posicion
    var property nivelDestino
    
    method accion() {
        nivelDestino.config()
    }
}

class Interactuable {
    var property image = "transparente.png"
    var property position = game.origin()
    var property activo = true
    
    method puedeInteractuar() = activo
    
    method accion() {
        // Método a sobrescribir por cada interactuable específico
    }
}

class BugCazable inherits Interactuable {
    var property nivel
    override method image() = "bug.png"

    override method accion() {
        if (nivel.juegoActivo()) {
            nivel.cazarBug()
            game.removeVisual(self)
            nivel.interactuables().remove(self)
        }
    }
}

class TerminalDeploy inherits Interactuable {
    override method image() = "terminal.png"

    override method accion() {
        cartelMensaje.texto("DEPLOY EXITOSO! VOLVIENDO...")
        cartelMensaje.activo(true)
        
        game.removeVisual(self)
        
        game.schedule(2000, {
            cartelMensaje.activo(false)
            nivelComputadoraV2.config()
        })
    }
}
object cartelMensaje {
    var property texto = ""
    var property activo = false
    
    method position() = cris.position().up(1)
    method text() = if (activo) texto else ""
    method textColor() = "00FF00"
}