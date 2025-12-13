import personajes.*

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

