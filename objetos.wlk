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

object ali inherits Interactuable(position = game.at(1, 5)) {
    var property dialogos = ["dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"]
    var property number = 0

    override method accion() {
        // Si ya hay un diálogo abierto, no hacemos nada (o podríamos cerrarlo)
        if (!game.hasVisual(pantallaDialogo)) {
            pantallaDialogo.image(dialogos.get(number))
            game.addVisual(pantallaDialogo)
            
            // Incrementamos para que la PRÓXIMA vez que se toque E, salga el siguiente
            number = (number + 1) % dialogos.size()
        }
    }
}

object gatito inherits Interactuable(position = game.at(3, 1)) {
    var property dialogoGatito = "gatitodialogo.png"

    override method accion() {
        if (!game.hasVisual(pantallaDialogo)) {
            pantallaDialogo.image(dialogoGatito)
            game.addVisual(pantallaDialogo)
        }
    }
}

object gatito2 inherits Interactuable(position = game.at(3, 1)) {
    var property dialogos = ["dialogogatito.png", "dialogogatito2.png", "dialogogatito3.png"]
    var property number = 0

    override method accion() {
        if (!game.hasVisual(pantallaDialogo)) {
            pantallaDialogo.image(dialogos.get(number))
            game.addVisual(pantallaDialogo)
            
            number = (number + 1) % dialogos.size()
        }
    }
}

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