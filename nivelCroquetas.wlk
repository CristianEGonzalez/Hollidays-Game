import niveles.*
import personajes.*
import objetos.*
import sonidos.*

object minijuegoCroquetas inherits NivelBase {
    var property puntos = 0
    var property perdidas = 0
    var property juegoActivo = false
    var property velocidadCris = 300
    var property velocidadGato = 120
    var property direccionDerecha = true
    var property controlManualActivo = true
    var property croquetaActiva = null

    var property gatosActivos = []
    var property platosActivos = []

    override method config() {
        game.clear()
        puntos = 0
        perdidas = 0
        velocidadCris = 300
        velocidadGato = 120
        juegoActivo = true

        gatosActivos.clear()
        platosActivos.clear()
        
        self.agregarFondo()
        
        cartelMensajeCroquetas.activo(false)
        game.addVisual(cartelMensajeCroquetas)
        game.addVisual(marcadorPuntos)
        
        game.addVisual(cris)
        cris.position(game.at(0, 14))
        cris.image("crispetit.png")

        self.crearPlato(3)
        self.crearPlatoInvisible(4)
        self.crearPlato(7)
        self.crearPlatoInvisible(8)
        self.crearPlato(11)
        self.crearPlatoInvisible(12)

        game.onTick(velocidadCris, "movimientoCris", { self.moverCris() })
        game.onTick(2500, "lanzarGato", { self.lanzarGato() })

        self.configurarTeclado()
    }

    method moverCris() {
        if (juegoActivo) {
            if (direccionDerecha) {
                if (cris.position().x() < 14)
                    cris.position(cris.position().right(1))
                else
                    direccionDerecha = false
            } else {
                if (cris.position().x() > 0)
                    cris.position(cris.position().left(1))
                else
                    direccionDerecha = true
            }
        }
    }

    method crearPlato(x) {
        const p = new Plato(position = game.at(x, 0))
        platosActivos.add(p)
        game.addVisual(p)
    }

    method crearPlatoInvisible(x) {
        const p = new PlatoInvisible(position = game.at(x, 0))
        platosActivos.add(p)
        game.addVisual(p)
    }

    method lanzarGato() {
        if (juegoActivo) {
            [0, 1, 2].forEach({ i =>
                game.schedule(i * 500, {
                    if (juegoActivo) {
                        const vieneDeIzquierda = (0..1).anyOne() == 1
                        const xInicial = if (vieneDeIzquierda) 0 else 14
                        
                        const gato = new GatoObstaculo(
                            position = game.at(xInicial, (4..10).anyOne()),
                            velocidad = velocidadGato,
                            vaHaciaDerecha = vieneDeIzquierda
                        )
                        gatosActivos.add(gato)
                        game.addVisual(gato)
                        gato.cruzar()
                    }
                })
            })
        }
    }

    override method configurarTeclado() {
        keyboard.space().onPressDo({ if (juegoActivo) self.soltarCroqueta() })
        keyboard.r().onPressDo({ self.config() })
        keyboard.left().onPressDo({ self.moverCroquetaEnAire(-1) })
        keyboard.right().onPressDo({ self.moverCroquetaEnAire(1) })
    }

    method moverCroquetaEnAire(dir) {
        if (controlManualActivo and croquetaActiva != null) {
            croquetaActiva.moverHorizontal(dir)
        }
    }

    method soltarCroqueta() {
        if (croquetaActiva == null) {
            const nueva = new Croqueta(position = cris.position().down(1))
            croquetaActiva = nueva
            game.addVisual(nueva)
            nueva.caer()
        }
    }

    method sumar() {
        puntos += 1
        velocidadCris = (velocidadCris - 15).max(70)
        velocidadGato = (velocidadGato - 8).max(40)
        
        game.removeTickEvent("movimientoCris")
        game.onTick(velocidadCris, "movimientoCris", { self.moverCris() })

        if (puntos >= 8) self.ganar()
    }

    method restar() {
        puntos = (puntos - 1).max(0)
        sonido.ejecutar(creadorDeSonidos.gatoMiau())
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

    override method agregarFondo() {
        game.addVisual(fondoCroquetas)
    }
}

class Croqueta {
    var property position
    var xOriginal = 0
    const rangoMovimiento = 1
    var property yaMovioEsteTick = false

    method initialize() {
        xOriginal = position.x()
    }

    method image() = "croqueta.png"

    method moverHorizontal(dir) {
        if (!yaMovioEsteTick) {
            const nuevaX = position.x() + dir
            if ((nuevaX - xOriginal).abs() <= rangoMovimiento) {
                position = game.at(nuevaX.max(0).min(14), position.y())
                yaMovioEsteTick = true
            }
        }
    }

    method caer() {
        game.onTick(70, "caida_" + self.identity().toString(), {
            if (position.y() > 0) {
                position = position.down(1)
                yaMovioEsteTick = false
                self.verificarImpacto()
            } else {
                minijuegoCroquetas.fallar()
                self.destruir()
            }
        })
    }
    
    method verificarImpacto() {

    if (minijuegoCroquetas.gatosActivos().any({ gato =>
        (gato.position().x() - position.x()).abs() <= 1 and
        (gato.position().y() - position.y()).abs() <= 1
    })) {
        minijuegoCroquetas.restar()
        self.destruir()
    }
    else if (minijuegoCroquetas.platosActivos().any({ plato =>
        plato.position().x() == position.x() and
        plato.position().y() == position.y()
    })) {
        minijuegoCroquetas.sumar()
        self.destruir()
    }
}


    method destruir() {
        game.removeTickEvent("caida_" + self.identity().toString())
        if (minijuegoCroquetas.croquetaActiva() == self) {
            minijuegoCroquetas.croquetaActiva(null)
        }
        game.removeVisual(self)
    }
}

class GatoObstaculo {
    var property position
    var property velocidad
    var property vaHaciaDerecha

    method image() = if (vaHaciaDerecha) "gato_camina.png" else "gato_camina2.png"

    method cruzar() {
        game.onTick(velocidad, "mov_gato_" + self.identity().toString(), {
            if (vaHaciaDerecha) {
                position = position.right(1)
                if (position.x() > 14) self.eliminar()
            } else {
                position = position.left(1)
                if (position.x() < 0) self.eliminar()
            }
        })
    }

    method eliminar() {
        game.removeTickEvent("mov_gato_" + self.identity().toString())
        minijuegoCroquetas.gatosActivos().remove(self)
        game.removeVisual(self)
    }
}

class Plato {
    var property position
    method image() = "platocroquetas.png"
}

class PlatoInvisible {
    var property position
    method image() = "transparente.png"
}

object marcadorPuntos {
    method position() = game.at(2, 15)
    method text() =
        "Logradas: " + minijuegoCroquetas.puntos() +
        "/8 | Perdidas: " + minijuegoCroquetas.perdidas() + "/8"
    method textColor() = "FFFFFF"
}

object cartelMensajeCroquetas {
    var property texto = ""
    var property activo = false
    method position() = game.at(7, 15)
    method text() = if (activo) texto else ""
    method textColor() = "FFFF00"
}

object fondoCroquetas {
    var property image = "fondogato.png"
    var property position = game.origin()
}
