import niveles.*
import personajes.*
import objetos.*
object minijuegoCroquetas inherits NivelBase {
    var property puntos = 0
    var property perdidas = 0
    var property juegoActivo = false
    var property velocidadCris = 300 
    var property velocidadGato = 150
    var property direccionDerecha = true

    override method config() {
        game.clear()
        puntos = 0
        perdidas = 0
        velocidadCris = 300
        velocidadGato = 150
        juegoActivo = true
        
        self.agregarFondo()
        
        cartelMensajeCroquetas.activo(false)
        game.addVisual(cartelMensajeCroquetas)
        
        game.addVisual(marcadorPuntos)
        
        game.addVisual(cris)
        cris.position(game.at(0, 14))
        cris.image("crispetit.png")

        self.crearPlato(3)
        self.crearPlato(7)
        self.crearPlato(11)

        game.onTick(velocidadCris, "movimientoCris", { self.moverCris() })
        game.onTick(3000, "lanzarGato", { self.lanzarGato() })

        self.configurarTeclado()
    }

    method moverCris() {
        if (juegoActivo) {
            if (direccionDerecha) {
                if (cris.position().x() < 14) { cris.position(cris.position().right(1)) } 
                else { direccionDerecha = false }
            } else {
                if (cris.position().x() > 0) { cris.position(cris.position().left(1)) } 
                else { direccionDerecha = true }
            }
        }
    }

    method crearPlato(x) { game.addVisual(new Plato(position = game.at(x, 0))) }

    method lanzarGato() {
        if (juegoActivo) {
            const gato = new GatoObstaculo(
                position = game.at(0, (4..10).anyOne()), 
                velocidad = velocidadGato
            )
            game.addVisual(gato)
            gato.cruzar()
        }
    }

    override method configurarTeclado() {
        keyboard.space().onPressDo({ if (juegoActivo) self.soltarCroqueta() })
        keyboard.r().onPressDo({ self.config() }) // Atajo de reinicio
    }

    method soltarCroqueta() {
        const nueva = new Croqueta(position = cris.position().down(1))
        game.addVisual(nueva)
        nueva.caer()
    }

    method sumar() {
        puntos += 1
        velocidadCris = (velocidadCris - 25).max(70)
        velocidadGato = (velocidadGato - 10).max(50)
        
        // Reiniciar el tick con la nueva velocidad
        game.removeTickEvent("movimientoCris")
        game.onTick(velocidadCris, "movimientoCris", { self.moverCris() })

        if (puntos >= 10) self.ganar()
    }

    method fallar() {
        perdidas += 1
        if (perdidas >= 8) self.perder()
    }

    method ganar() {
        juegoActivo = false
        self.detenerEventos()
        cartelMensajeCroquetas.texto("¡PLATOS LLENOS! VOLVIENDO...")
        cartelMensajeCroquetas.activo(true)
        game.schedule(2000, { nivelHabitacionV2.config() })
    }

    method perder() {
        juegoActivo = false
        self.detenerEventos()
        cartelMensajeCroquetas.texto("¡FALLASTE! (R PARA REINTENTAR)")
        cartelMensajeCroquetas.activo(true)
    }

    method detenerEventos() {
        game.removeTickEvent("movimientoCris")
        game.removeTickEvent("lanzarGato")
    }
}

class Croqueta {
    var property position
    method image() = "croqueta.png"

    method caer() {
        game.onTick(100, "caida_" + self.identity().toString(), {
            if (position.y() > 0) {
                position = position.down(1)
                self.verificarImpacto()
            } else {
                minijuegoCroquetas.fallar()
                self.destruir()
            }
        })
    }

    method verificarImpacto() {
        const colisiones = game.colliders(self)
        if (colisiones.any({ v => v.image() == "gato_camina.png" })) {
            self.destruir()
        } else {
            if (colisiones.any({ v => v.image() == "plato_croquetas.png" })) {
                minijuegoCroquetas.sumar()
                self.destruir()
            }
        }
    }

    method destruir() {
        game.removeTickEvent("caida_" + self.identity().toString())
        game.removeVisual(self)
    }
}

class GatoObstaculo {
    var property position
    var property velocidad 
    method image() = "gato_camina.png"

    method cruzar() {
        game.onTick(velocidad, "mov_gato_" + self.identity().toString(), {
            position = position.right(1)
            if (position.x() > 14) {
                game.removeTickEvent("mov_gato_" + self.identity().toString())
                game.removeVisual(self)
            }
        })
    }
}

class Plato {
    var property position
    method image() = "plato_croquetas.png"
}


object marcadorPuntos {
    method position() = game.at(0, 14)
    method text() = "Logradas: " + minijuegoCroquetas.puntos() + "/10 | Perdidas: " + minijuegoCroquetas.perdidas() + "/8"
    method textColor() = "FFFFFF"
}

object cartelMensajeCroquetas {
    var property texto = ""
    var property activo = false
    method position() = game.at(4, 8)
    method text() = if (activo) texto else ""
    method textColor() = "FFFF00"
}