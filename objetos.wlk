import personajes.*
import niveles.*
class Bloqueador {
    var property position = game.origin()
    method esBloqueador() = true
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

object gatito inherits PersonajeConDialogo(position = game.at(3, 1), dialogos = ["gatitodialogo1.png", "gatitodialogo.png"]) {
    var property dormido = false
    const dialogosDormido = ["dialogogatito.png", "dialogogatito2.png", "dialogogatito3.png"]
    
    method obtenerDialogosActuales() {
        return if (dormido) 
            dialogosDormido
        else
            dialogos
    }
    
    override method accion() {
        if (!game.hasVisual(pantallaDialogo)) {
            const dialogosActuales = self.obtenerDialogosActuales()
            pantallaDialogo.image(dialogosActuales.get(indice))
            game.addVisual(pantallaDialogo)
            self.avanzarDialogo()
        }
    }
    
    override method avanzarDialogo() {
        const dialogosActuales = self.obtenerDialogosActuales()
        indice = (indice + 1) % dialogosActuales.size()
    }
    
    method dormir() {
        dormido = true
        indice = 0
    }
    
    method despertar() {
        dormido = false
        indice = 0
    }
}

object ali inherits PersonajeConDialogo(position = game.at(1, 5), dialogos = ["dialogoali.png", "dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"]) {
    const dialogosHabitacionNormal = ["dialogoali.png", "dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"]
    const dialogosDesayuno = ["dialogoalipanqueque.png"]
    
    method configurarHabitacionNormal() {
        position = game.at(1, 5)
        self.cambiarDialogos(dialogosHabitacionNormal)
    }
    
    method configurarDesayuno() {
        position = game.at(2, 3)
        self.cambiarDialogos(dialogosDesayuno)
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