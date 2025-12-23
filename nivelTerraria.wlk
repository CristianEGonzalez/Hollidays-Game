import niveles.*
import personajes.*
import objetos.*

object nivelTerraria inherits NivelComputadoraBase {
    var property vidaBoss = 8
    var property municion = 10
    var property juegoActivo = false

    override method config() {
        self.detenerEventos() // Limpieza total antes de empezar
        game.clear()
        
        self.agregarFondo()
        game.addVisual(cris)
        cris.position(game.at(8, 4))
        cris.image("crispetit.png")
        
        // Estado inicial
        juegoActivo = true
        vidaBoss = 10
        municion = 10
        ojoBoss.position(game.at(8, 12))
        ojoBoss.pasosVerticales(0)
        ojoBoss.fase(1)
        
        game.addVisual(ojoBoss)
        ojoBoss.iniciarMovimiento()
        
        cartelMensaje.activo(false)
        game.addVisual(cartelMensaje)
        game.addVisual(marcadorVidaBoss)
        game.addVisual(marcadorMunicion)
        
        game.onTick(2000, "disparoBoss", { ojoBoss.disparar() })
        
        keyboard.space().onPressDo({ self.intentarDisparar() })
        keyboard.e().onPressDo({ self.recargar() })
        
        self.configurarTeclado()
        self.agregarAreaBloqueada(0, 15, 5, 5)
        self.agregarAreaBloqueada(0, 15, 2, 2)
    }

    method intentarDisparar() {
        if (juegoActivo and municion > 0) {
            municion -= 1
            const flecha = new FlechaTerraria(position = cris.position().up(1))
            game.addVisual(flecha)
            flecha.moverse()
        } else if (juegoActivo and municion <= 0) {
            game.say(cris, "¡E para recargar!")
        }
    }

    method recargar() {
        if (juegoActivo) {
            game.say(cris, "Recargando...")
            game.schedule(1000, { if(juegoActivo) municion = 10 })
        }
    }

    method bossHerido() {
    vidaBoss -= 1
    
    if (vidaBoss == 0) {
        self.victoria()
    } else if (vidaBoss <= 4) {
        ojoBoss.fase(3) // Fase 3: X 0-15, Y 3-12
    } else if (vidaBoss <= 7) {
        ojoBoss.fase(2) // Fase 2: X 0-15, Y 6-14
    }
}

    method realizarEmbestida() {
        if (juegoActivo) {
            const xActual = ojoBoss.position().x()
            
            ojoBoss.position(game.at(xActual, 4))
            
            if (ojoBoss.position().x() == cris.position().x()) { 
                self.morir("¡EL OJO TE DESINTEGRÓ EN LA EMBESTIDA!") 
            }
            
            game.schedule(500, { 
                if(juegoActivo) ojoBoss.position(game.at(ojoBoss.position().x(), 12)) 
            })
        }
    }

    method morir(mensaje) {
        juegoActivo = false
        self.detenerEventos()
        
        cartelMensaje.texto(mensaje)
        cartelMensaje.activo(true)
        
        // Reiniciamos el nivel después de 5 segundos
        game.schedule(5000, { self.config() })
    }

    method detenerEventos() {
        // Removemos todos los eventos posibles por nombre
        const eventos = ["disparoBoss", "movimientoBoss", "azarEmbestida", "cuentaRegresiva"]
        eventos.forEach({ e => try { game.removeTickEvent(e) } catch ex : Exception {} })
    }

    method victoria() {
        juegoActivo = false
        self.detenerEventos()
        game.removeVisual(ojoBoss)
        cartelMensaje.texto("¡OJO DERROTADO!")
        cartelMensaje.activo(true)
        game.schedule(3000, {
            cartelMensaje.activo(false)
            nivelComputadoraV3.config()
        })
    }

    override method agregarFondo() { game.addVisual(fondoTerraria) }
}
object ojoBoss {
    var property position = game.at(8, 12)
    var property direccionX = 1 
    var property fase = 1
    var property pasosVerticales = 0 
    var property direccionVertical = -1 // -1 para subir, 1 para bajar

    method image() = if (fase == 3) "ojo_boss_fase2.png" else "ojo_boss.png"

    method iniciarMovimiento() {
        // Reiniciar variables de movimiento al cambiar fase
        pasosVerticales = 0
        direccionVertical = -1
        
        // Tick base de 150ms. En fase 3 se mueve doble.
        game.onTick(150, "movimientoBoss", {
            self.actualizarPosicion()
            if (fase == 3) { self.actualizarPosicion() }
        })
    }

    method actualizarPosicion() {
        // 1. Movimiento Horizontal (X: 0 a 15)
        if (position.x() >= 15) direccionX = -1
        if (position.x() <= 0) direccionX = 1
        
        var nuevaX = position.x() + direccionX
        var nuevaY = position.y()

        // 2. Lógica de Fases
        if (fase == 1) {
            // FASE 1: Solo derecha a izquierda arriba (se queda en Y=12 fijo)
            nuevaY = 12
        } 
        else if (fase == 2) {
            // FASE 2: Y de 6 a 14 (Rango de 8 celdas)
            // Cambiar dirección vertical si llega a los límites
            if (nuevaY <= 6) direccionVertical = 1  // Cambia a bajar
            if (nuevaY >= 14) direccionVertical = -1 // Cambia a subir
            
            nuevaY = position.y() + direccionVertical
        } 
        else {
            // FASE 3: Y de 3 a 12 (Rango de 9 celdas)
            // Cambiar dirección vertical si llega a los límites
            if (nuevaY <= 3) direccionVertical = 1  // Cambia a bajar
            if (nuevaY >= 12) direccionVertical = -1 // Cambia a subir
            
            nuevaY = position.y() + direccionVertical
        }

        // Asegurarse de que Y está dentro de los límites
        if (fase == 2) {
            if (nuevaY < 6) nuevaY = 6
            if (nuevaY > 14) nuevaY = 14
        } else if (fase == 3) {
            if (nuevaY < 3) nuevaY = 3
            if (nuevaY > 12) nuevaY = 12
        }

        position = game.at(nuevaX, nuevaY)

        // Colisión con Cris
        if (self.position() == cris.position()) {
            nivelTerraria.morir("¡EL OJO TE PASÓ POR ENCIMA!")
        }
    }

    method disparar() {
        if (nivelTerraria.juegoActivo()) {
            const miniOjo = new ProyectilBoss(position = self.position().down(1))
            game.addVisual(miniOjo)
            miniOjo.caer()
        }
    }
    
    method fase(nuevaFase) {
        fase = nuevaFase
        if (fase == 1) {
            position = game.at(position.x(), 12)
        } else if (fase == 2) {
            position = game.at(position.x(), 10)
        } else {
            position = game.at(position.x(), 7)
        }
        pasosVerticales = 0
        direccionVertical = -1
    }
}

object marcadorMunicion {
    method position() = game.at(12, 14)
    method text() = "FLECHAS: " + nivelTerraria.municion()
    method textColor() = "FFFF00" // Amarillo
}

object marcadorVidaBoss {
    method position() = game.at(1, 14)
    method text() = "BOSS HP: " + nivelTerraria.vidaBoss()
    method textColor() = "FF0000"
}
class FlechaTerraria {
    var property position
    method image() = "flecha.png"

    method moverse() {
        game.onTick(100, "flechaSube_" + self.identity().toString(), {
            position = position.up(1)
            
            // Colisión con el boss (X igual y Y cerca o arriba)
            if (position.x() == ojoBoss.position().x() and position.y() >= ojoBoss.position().y()) {
                nivelTerraria.bossHerido()
                self.destruir()
            } else if (position.y() >= 15) {
                self.destruir()
            }
        })
    }

    method destruir() {
        game.removeTickEvent("flechaSube_" + self.identity().toString())
        game.removeVisual(self)
    }
}

class ProyectilBoss {
    var property position
    method image() = "ojo_mini.png"

    method caer() {
        game.onTick(150, "ojoCae_" + self.identity().toString(), {
            position = position.down(1)
            
            if (position == cris.position()) {
                nivelTerraria.morir("¡EL OJO TE COMIÓ!")
            }
            
            if (position.y() <= 0) {
                self.destruir()
            }
        })
    }
    
    method destruir() {
        game.removeTickEvent("ojoCae_" + self.identity().toString())
        game.removeVisual(self)
    }
}

object fondoTerraria {
    var property image = "terraria.png"
    var property position = game.origin()
}

