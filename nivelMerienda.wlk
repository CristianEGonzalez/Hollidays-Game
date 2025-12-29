import niveles.*
import personajes.*
import objetos.*

object minijuegoPanqueques inherits NivelComputadoraBase {
    var property faseActual = 1 // 1: Memoria, 2: Mezcla, 3: Cocción
    var property juegoActivo = false
    var property tiempoRestante = 60
    
    // Variables Fase 1 (Memoria)
    const recetaRequerida = ["Harina", "Leche", "Huevo"]
    var property recetaUsuario = []

    // Variables Fase 2 (Mezcla)
    var property progresoMezcla = 0
    var property selectorX = 0
    var property dirSelector = 1

    // Variables Fase 3 (Cocción)
    var property panquequesListos = 0
    const objetivoSartenes = 6
    const sartenes = [
        new Sarten(position = game.at(3, 7), id = 1),
        new Sarten(position = game.at(7, 7), id = 2),
        new Sarten(position = game.at(11, 7), id = 3)
    ]

    override method config() {
        game.clear()
        self.agregarFondo()
        
        // Reinicio de variables de estado
        juegoActivo = true
        faseActual = 1
        recetaUsuario = []
        tiempoRestante = 60
        panquequesListos = 0
        progresoMezcla = 0
        
        game.addVisual(cris)
        cris.position(game.at(8, 2))
        
        self.configurarTeclado() 
        self.configurarBloqueadores()
        
        game.addVisual(marcadorGeneral)
        game.onTick(1000, "tiempoGlobal", { self.tickTiempo() })
        
        self.iniciarFase1()
    }

    override method configurarBloqueadores() {
        bloqueadores.clear()
    }

    override method configurarTeclado() {
        super()
        
        keyboard.e().onPressDo({ self.procesarInteraccion() })
        keyboard.space().onPressDo({ if (faseActual == 2) self.batir() })
        keyboard.a().onPressDo({ if (faseActual == 3) self.intentarSacar(0) })
        keyboard.s().onPressDo({ if (faseActual == 3) self.intentarSacar(1) })
        keyboard.d().onPressDo({ if (faseActual == 3) self.intentarSacar(2) })
        keyboard.r().onPressDo({ self.config() })
    }

    method tickTiempo() {
        if (juegoActivo) {
            tiempoRestante -= 1
            if (tiempoRestante <= 0) self.perder()
        }
    }

    // --- FASE 1: MEMORIA ---
    method iniciarFase1() {
        const ingredientes = [
            new Ingrediente(nombre = "Harina", position = game.at(4, 10)),
            new Ingrediente(nombre = "Leche", position = game.at(7, 10)),
            new Ingrediente(nombre = "Huevo", position = game.at(10, 10)),
            new Ingrediente(nombre = "Sal", position = game.at(4, 6)),
            new Ingrediente(nombre = "Pimienta", position = game.at(7, 6)),
            new Ingrediente(nombre = "Calcetin", position = game.at(10, 6))
        ]
        
        interactuables.clear()
        ingredientes.forEach({ i =>
            game.addVisual(i)
            self.agregarInteractuable(i)
        })
        
        game.addVisual(notaReceta)
        game.schedule(4000, { 
            if (game.hasVisual(notaReceta)) game.removeVisual(notaReceta)
        })
    }

    method agregarIngrediente(nombre) {
        if (faseActual == 1){
        
        if (!recetaUsuario.contains(nombre)){

        const proximoCorrecto = recetaRequerida.get(recetaUsuario.size())
        
        if (nombre == proximoCorrecto) {
            recetaUsuario.add(nombre)
            game.say(cris, "¡" + nombre + "!")
            
            if (recetaUsuario.size() == recetaRequerida.size()) {
                game.say(cris, "¡Masa lista!")
                game.schedule(1000, { self.iniciarFase2() })
            }
        } else {
            game.say(cris, "¡Ese no!")
            recetaUsuario = []
            tiempoRestante -= 5
        }}
    }}

    // --- FASE 2: MEZCLA ---
    method iniciarFase2() {
        faseActual = 2
        game.allVisuals().forEach({ v => 
            if(v != marcadorGeneral and v != cris) game.removeVisual(v) 
        })
        self.agregarFondo()
        
        game.addVisual(barraMezcla)
        game.addVisual(selectorMezcla)
        game.onTick(50, "moverSelector", { self.moverSelector() })
    }

    method moverSelector() {
        if (selectorX >= 10) dirSelector = -1
        if (selectorX <= 0) dirSelector = 1
        selectorX += dirSelector
        selectorMezcla.position(game.at(3 + selectorX, 5))
    }

    method batir() {
        if (selectorX.between(4, 6)) {
            progresoMezcla += 20
            game.say(cris, "¡Bien!")
            if (progresoMezcla >= 100) {
                game.removeTickEvent("moverSelector")
                self.iniciarFase3()
            }
        } else {
            game.say(cris, "¡Mal!")
        }
    }

    // --- FASE 3: COCCIÓN ---
    method iniciarFase3() {
        faseActual = 3
        game.allVisuals().forEach({ v => 
            if(v != marcadorGeneral and v != cris) game.removeVisual(v) 
        })
        self.agregarFondo()
        
        sartenes.forEach({ s => 
            game.addVisual(s)
            s.iniciar()
        })
    }

    method intentarSacar(indice) {
        if (faseActual == 3){
        const s = sartenes.get(indice)
        if (s.estado() == 2) {
            panquequesListos += 1
            game.say(s, "+1")
            s.reiniciar()
            if (panquequesListos >= objetivoSartenes) self.victoria()
        } else {
            game.say(s, "¡Fallo!")
            s.reiniciar()
        }
    }}

    method victoria() {
        juegoActivo = false
        sartenes.forEach({ s => s.detener() })
        game.say(cris, "¡Ali, a comer!")
        game.schedule(2000, { nivelHabitacionV2.config() })
    }

    method perder() {
        juegoActivo = false
        game.say(cris, "Perdí... (R)")
    }
}

// --- CLASES ---
class Ingrediente inherits Interactuable {
    var property nombre
    override method image() = nombre.toLowerCase() + ".png"
    override method accion() { minijuegoPanqueques.agregarIngrediente(nombre) }
}

class Sarten {
    var property position
    var property id
    var property estado = 1 
    var property tiempo = 0

    method image() = "sarten_" + estado.toString() + ".png"

    method iniciar() {
        self.reiniciar()
        game.onTick(1000, "cocinar_" + id.toString(), { self.cocinar() })
    }

    method cocinar() {
        tiempo += 1
        if (tiempo == 3) estado = 2
        if (tiempo == 6) estado = 3
        if (tiempo >= 8) self.reiniciar()
    }

    method reiniciar() {
        estado = 1
        tiempo = - (0 .. 4).anyOne()
    }

    method detener() {
        try { game.removeTickEvent("cocinar_" + id.toString()) } catch e : Exception {}
    }
}

// --- OBJETOS VISUALES ---
object notaReceta {
    method image() = "nota_receta.png"
    method position() = game.at(6, 4)
}

object barraMezcla {
    method image() = "barra_mezcla.png"
    method position() = game.at(3, 5)
}

object selectorMezcla {
    var property position = game.at(3, 5)
    method image() = "selector.png"
}

object marcadorGeneral {
    method text() = "TIEMPO: " + minijuegoPanqueques.tiempoRestante() + 
                    " | FASE: " + minijuegoPanqueques.faseActual() +
                    " | LISTOS: " + minijuegoPanqueques.panquequesListos()
    method position() = game.at(1, 14)
}

object fondoCocinaPanqueques {
    method image() = "fondo_cocina.png"
    method position() = game.origin()
}