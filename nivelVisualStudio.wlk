import niveles.*
import personajes.*
import objetos.*
import sonidos.*

object nivelVisualStudio inherits NivelComputadoraBase {
    var property bugsCazados = 0
    var property tiempoRestante = 25
    const bugsObjetivo = 12
    var property juegoActivo = false

    override method agregarFondo() {
        game.addVisual(fondoVSCode)
    }

    override method musicaDeNivel() = "musica_vs.mp3"

    override method configurarPersonaje() {
        cris.position(game.at(8, 8))
        cris.image("crispetit.png")
    }

    override method configurarTeclado() {
        super()
        // Permitir reiniciar si falla
        keyboard.r().onPressDo({ self.config() })
    }

    override method config() {
        if (juegoActivo) { self.detenerEventos() }
        game.clear()
        
        self.agregarFondo()
        game.addVisual(cris)
        self.configurarPersonaje()
        
        // Se agrega el cartel de textos
        cartelMensaje.activo(false)
        game.addVisual(cartelMensaje)
        
        self.iniciarMinijuego()
        game.addVisual(marcadorByteland)
        self.configurarTeclado()
    }

    method iniciarMinijuego() {
        bugsCazados = 0
        tiempoRestante = 25
        juegoActivo = true
        
        game.onTick(1500, "aparecerBug", { self.generarBug() })
        game.onTick(1000, "cuentaRegresiva", { self.tickTiempo() })
    }

    method generarBug() {
        if (juegoActivo) {
            const x = (1 .. 14).anyOne()
            const y = (4 .. 13).anyOne()
            const nuevoBug = new BugCazable(position = game.at(x, y), nivel = self)
            
            self.agregarInteractuable(nuevoBug) // Se suma a la lista de colisiones
            game.addVisual(nuevoBug)
            
            game.schedule(2000, { 
                if(game.hasVisual(nuevoBug)) {
                    game.removeVisual(nuevoBug)
                    interactuables.remove(nuevoBug) // Limpieza de la lista para que no crezca infinito
                }
            })
        }
    }

    method cazarBug() {
        sonido.ejecutar(creadorDeSonidos.bug())
        bugsCazados += 1
    }

    method tickTiempo() {
        tiempoRestante -= 1
        if (tiempoRestante <= 0) { self.finalizarTiempo() }
    }

    method detenerEventos() {
        game.removeTickEvent("aparecerBug")
        game.removeTickEvent("cuentaRegresiva")
    }

    method finalizarTiempo() {
        juegoActivo = false
        self.detenerEventos()
        
        if (bugsCazados >= bugsObjetivo) {
            cartelMensaje.texto("¡DEPLOY LISTO! IR A LA TERMINAL")
            const terminal = new TerminalDeploy(position = game.at(14, 4))
            self.agregarInteractuable(terminal)
            game.addVisual(terminal)
        } else {
            cartelMensaje.texto("FALLASTE! (R PARA REINTENTAR)")
        }
        
        cartelMensaje.activo(true) // mostrar el texto
        game.schedule(4000, { cartelMensaje.activo(false) })
    }
}

object marcadorByteland {
    method position() = game.at(1, 14)
    method text() = "BUGS: " + nivelVisualStudio.bugsCazados() + " / " + 12 + " | TIEMPO: " + nivelVisualStudio.tiempoRestante()
    method textColor() = "FFFFFF"
}

object fondoVSCode {
    var property image = "fondovs.png"
    var property position = game.origin()
}