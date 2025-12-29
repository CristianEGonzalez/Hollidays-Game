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
    var property position
    var property activo = true
    
    method puedeInteractuar() = activo
    
    method accion() {
        // Método a sobrescribir por cada interactuable específico
    }
}

object pantallaDialogo {
    var property image = ""
    var property position = game.origin() // (0,0) para que cubra la pantalla
}

class PersonajeConDialogo inherits Interactuable {
    var property dialogos = []
    var property indice = 0

    override method accion() {
        if (!game.hasVisual(pantallaDialogo)) {
            pantallaDialogo.image(dialogos.get(indice))
            game.addVisual(pantallaDialogo)
            self.avanzarDialogo()
        }
    }

    method avanzarDialogo() {
        indice = (indice + 1) % dialogos.size()
    }
    
    // Método para cambiar diálogos dinámicamente si es necesario
    method cambiarDialogos(nuevosDialogos) {
        dialogos = nuevosDialogos
        indice = 0
    }
}

object gatito inherits PersonajeConDialogo(position = game.at(3, 1), dialogos = ["gatitodialogo1.png", "gatitodialogo.png"]) {}

object gatito2 inherits PersonajeConDialogo(position = game.at(3, 1), dialogos = ["dialogogatito.png", "dialogogatito2.png", "dialogogatito3.png"]) {}

object ali inherits PersonajeConDialogo(position = game.at(1, 5), dialogos = ["dialogoali.png", "dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"]) {}

object pizarron inherits Interactuable(position = game.at(14, 8)) {
    var property pizarron = "pizarronzoom.png"

    override method accion() {
        if (!game.hasVisual(pantallaDialogo)) {
            pantallaDialogo.image(pizarron)
            game.addVisual(pantallaDialogo)
        }
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
            nivelComputadoraV3.config()
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