import niveles.*
import personajes.*
import objetos.*

object minijuegoPanqueques inherits NivelComputadoraBase {
    var property faseActual = 1 // 1: Memoria, 2: Mezcla, 3: Cocción
    var property juegoActivo = false
    var property tiempoRestante = 70
    var property consultasReceta = 1 // Permitimos una consulta extra
    var property puedeInteractuar = true
    
    // Variables Fase 1 (Memoria)
    const recetasPosibles = [
        ["harina", "leche", "huevo", "huevo", "manteca", "dulcedeleche"],
        ["manteca", "leche", "huevo", "harina", "huevo", "dulcedeleche"],
        ["dulcedeleche", "huevo", "huevo", "manteca", "harina", "leche"]
    ]
    var property recetaElegida = []
    var property indiceReceta = 0
    var property recetaUsuario = []

    // Variables Fase 2 (Mezcla)
    var property progresoMezcla = 0
    var property selectorX = 0
    var property dirSelector = 1
    var property zonaObjetivoActual = 0

    // Variables Fase 3 (Cocción)
    var property panquequesListos = 0
    const objetivoSartenes = 12
    const sartenes = [
        new Sarten(position = game.at(3, 10), id = 1, tecla = "A"),
        new Sarten(position = game.at(7, 10), id = 2, tecla = "S"),
        new Sarten(position = game.at(11, 10), id = 3, tecla = "D"),
        new Sarten(position = game.at(3, 5), id = 4, tecla = "V"),
        new Sarten(position = game.at(7, 5), id = 5, tecla = "B"),
        new Sarten(position = game.at(11, 5), id = 6, tecla = "N")
    ]

    override method config() {
        game.clear()
        self.agregarFondo()
        
        // Reinicio de variables de estado
        juegoActivo = false // Empieza en false hasta que se oculte la receta
        faseActual = 1
        recetaUsuario = []
        tiempoRestante = 70
        panquequesListos = 0
        progresoMezcla = 0
        zonaObjetivoActual = 0
        consultasReceta = 1

        // Selección Aleatoria de Receta
        indiceReceta = (0..2).anyOne()
        recetaElegida = recetasPosibles.get(indiceReceta)
        
        self.configurarTeclado()
        self.configurarBloqueadores()
        
        game.addVisual(marcadorGeneral)
        game.addVisual(cartelMensaje)
        game.onTick(1000, "tiempoGlobal", { self.tickTiempo() })
        
        self.iniciarFase1()
    }

    override method agregarFondo() { game.addVisual(fondoCocinaPanqueques) }

    override method configurarBloqueadores() {
        bloqueadores.clear()
    }

    override method musicaDeNivel() = "musica_merienda.mp3"

    override method configurarTeclado() {
        keyboard.up().onPressDo({ if (faseActual == 1) moverArriba.mover() })
        keyboard.down().onPressDo({ if (faseActual == 1) moverAbajo.mover() })
        keyboard.left().onPressDo({ if (faseActual == 1) moverIzquierda.mover() })
        keyboard.right().onPressDo({ if (faseActual == 1) moverDerecha.mover() })
        keyboard.c().onPressDo({ if (faseActual == 1) self.consultarReceta() })

        keyboard.e().onPressDo({ if (faseActual == 1) self.procesarInteraccion() })
        keyboard.space().onPressDo({ if (faseActual == 2) self.batir() })
        
        keyboard.a().onPressDo({ if (faseActual == 3) self.intentarSacar(0) })
        keyboard.s().onPressDo({ if (faseActual == 3) self.intentarSacar(1) })
        keyboard.d().onPressDo({ if (faseActual == 3) self.intentarSacar(2) })
        keyboard.v().onPressDo({ if (faseActual == 3) self.intentarSacar(3) })
        keyboard.b().onPressDo({ if (faseActual == 3) self.intentarSacar(4) })
        keyboard.n().onPressDo({ if (faseActual == 3) self.intentarSacar(5) })

        keyboard.r().onPressDo({ self.config() })
    }

    method mostrarCartel(msj) {
        cartelMensaje.texto(msj)
        cartelMensaje.activo(true)
        game.schedule(2000, { cartelMensaje.activo(false) })
    }

    method tickTiempo() {
        if (juegoActivo) {
            tiempoRestante = (tiempoRestante - 1).max(0) // Evita negativos
            if (tiempoRestante == 0) self.perder()
        }
    }

    // --- FASE 1: MEMORIA ---
    method iniciarFase1() {
        const nombres = [
            "harina", "chocolate", "tomate", "dulcedeleche", "sal", "leche",
            "azucar", "arroz", "manteca", "vainilla", "huevo", "aceite"
        ]

        interactuables.clear()

        (0 .. nombres.size() - 1).forEach({ i =>
            const nombre = nombres.get(i)
            
            // Lógica de posición: 6 por fila
            // Fila 1 (i: 0-5): y = 6 | Fila 2 (i: 6-11): y = 4
            const posX = (i % 6) * 2 + 2
            const posY = if (i < 6) 6 else 4
            
            const ing = new Ingrediente(nombre = nombre, position = game.at(posX, posY))
            game.addVisual(ing)
            self.agregarInteractuable(ing)
        })

        if (game.hasVisual(cris)) game.removeVisual(cris)
        game.addVisual(cris)
        cris.position(game.at(7, 2))
        cris.image("crispetit.png")

        if (game.hasVisual(cartelMensaje)) game.removeVisual(cartelMensaje)
        game.addVisual(cartelMensaje)
        
        self.mostrarReceta()
    }

    method mostrarReceta() {
        juegoActivo = false // Pausa el tiempo
        game.addVisual(notaReceta)
        game.schedule(4000, {
            if (game.hasVisual(notaReceta)) {
                game.removeVisual(notaReceta)
                juegoActivo = true // Reanuda el tiempo
            }
        })
    }

    method consultarReceta() {
        if (consultasReceta > 0 and !game.hasVisual(notaReceta)) {
            consultasReceta -= 1
            self.mostrarReceta()
        } else if (consultasReceta == 0) {
            self.mostrarCartel("¡No podes ver mas la receta!")
        }
    }

    method agregarIngrediente(nombre) {
        // 1. Verificamos que el juego esté activo y que todavía falten ingredientes por recolectar
        if (faseActual == 1 and juegoActivo and puedeInteractuar and recetaUsuario.size() < recetaElegida.size()) {
            
            puedeInteractuar = false
            game.schedule(200, { puedeInteractuar = true })

            const indiceActual = recetaUsuario.size()
            const proximoCorrecto = recetaElegida.get(indiceActual)

            if (nombre == proximoCorrecto) {
                recetaUsuario.add(nombre)
                self.mostrarCartel("¡" + nombre + "!")
                
                // Si terminamos, pasamos a la fase 2
                if (recetaUsuario.size() == recetaElegida.size()) {
                    juegoActivo = false // Pausamos interacciones
                    game.schedule(1000, { self.iniciarFase2() })
                }
            } else {
                self.mostrarCartel("¡MAL! Era " + proximoCorrecto)
                recetaUsuario = [] // Reinicia
                tiempoRestante = (tiempoRestante - 3).max(0)
                if (tiempoRestante == 0) self.perder()
            }
        }
    }


    // --- FASE 2: MEZCLA ---
    method iniciarFase2() {
        faseActual = 2
        zonaObjetivoActual = 0
        selectorX = 0
        dirSelector = 0.2

        cris.position(game.at(7, 7))
        cris.image("transparente.png")
        
        self.limpiarPantallaGeneral() // Quita a Cris y demás objetos
        self.actualizarFondoMezcla()
        
        game.addVisual(selectorMezcla)
        game.onTick(50, "moverSelector", { self.moverSelector() })
    }

    method actualizarFondoMezcla() {
        // Cambia el fondo según la zona (fondococina_1, fondococina_2, fondococina_3)
        fondoCocinaPanqueques.image("fondococina_" + (zonaObjetivoActual + 1).toString() + ".png")
    }

    method limpiarPantalla(objetosEsenciales) {
        game.allVisuals().forEach({ v =>
            if (!objetosEsenciales.contains(v)) {
                game.removeVisual(v)
            }
        })
    }

    method limpiarPantallaMezcla() {
        self.limpiarPantalla([fondoCocinaPanqueques, marcadorGeneral, cartelMensaje, cris, selectorMezcla])
    }

    method limpiarPantallaGeneral() {
        self.limpiarPantalla([fondoCocinaPanqueques, marcadorGeneral, cartelMensaje])
        if (game.hasVisual(cris)) game.removeVisual(cris)
    }

    method limpiarPantallaCoccion() {
        self.limpiarPantalla([fondoCocinaPanqueques, marcadorGeneral, cartelMensaje])
    }

    method limpiarPantallaFinal() {
        self.limpiarPantalla([marcadorGeneral, cris, cartelMensaje])
        self.agregarFondo()
        if (!game.hasVisual(cartelMensaje)) game.addVisual(cartelMensaje)
    }

    method moverSelector() {
        if (selectorX >= 10) dirSelector = -0.2
        if (selectorX <= 0) dirSelector = 0.2
        selectorX += dirSelector
        selectorMezcla.position(game.at(3 + selectorX, 3))
    }

    method batir() {
        // Objetivos relativos a la base X=3:
        // Mezcla 1: X=4,5 -> relativo 1.5 (centro entre 1 y 2)
        // Mezcla 2: X=11,12 -> relativo 8.5 (centro entre 8 y 9)
        // Mezcla 3: X=8,9 -> relativo 5.5 (centro entre 5 y 6)
        const objetivosRelativos = [1.5, 8.5, 5.5]
        const objetivoActual = objetivosRelativos.get(zonaObjetivoActual)

        // Margen de 1.0 (cubre las 2 celdas indicadas)
        if (selectorX.between(objetivoActual - 1.0, objetivoActual + 1.0)) {
            zonaObjetivoActual += 1
            
            if (zonaObjetivoActual >= 3) {
                game.removeTickEvent("moverSelector")
                self.mostrarCartel("¡Mezcla lista!")
                game.schedule(1000, { self.iniciarFase3() })
            } else {
                self.mostrarCartel("¡Bien! Siguiente...")
                self.actualizarFondoMezcla()
                self.limpiarPantallaMezcla()
            }
        } else {
            self.mostrarCartel("¡FALLO! -3 seg")
            tiempoRestante = (tiempoRestante - 3).max(0)
            if (tiempoRestante == 0) self.perder()
        }
    }

    // --- FASE 3: COCCIÓN ---
    method iniciarFase3() {
        faseActual = 3
        juegoActivo = true

        cris.position(game.at(7, 7))
        cris.image("transparente.png")
        
        self.limpiarPantallaGeneral()
        fondoCocinaPanqueques.image("fondosarten.png")
        
        sartenes.forEach({ s =>
            game.addVisual(s)
            s.iniciar()
        })
        
        self.mostrarCartel("¡Cocina 12 panqueques!")
    }

    method intentarSacar(indice) {
        if (faseActual == 3 and juegoActivo) {
            const s = sartenes.get(indice)
            
            if (s.estado() == 2) { // COCIDO
                panquequesListos += 1
                self.mostrarCartel("¡Perfecto! " + panquequesListos + "/12")
                s.reiniciar()
                if (panquequesListos >= objetivoSartenes) self.victoria()
            } else { // CRUDO (1) o QUEMADO (3)
                const msg = if (s.estado() == 1) "¡CRUDO! -3s" else "¡QUEMADO! -3s"
                self.mostrarCartel(msg)
                s.reiniciar()
                tiempoRestante = (tiempoRestante - 3).max(0)
                if (tiempoRestante == 0) self.perder()
            }
        }
    }

    method victoria() {
        juegoActivo = false
        sartenes.forEach({ s => s.detener() })
        self.mostrarCartel("¡Panqueques listos para comer!")
        game.schedule(2000, { nivelHabitacionV4.config() })
    }

    method perder() {
        juegoActivo = false
        sartenes.forEach({ s => s.detener() })
        game.removeTickEvent("moverSelector")
        self.mostrarCartel("PERDISTE (R para reiniciar)")
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
    var property tecla
    var property estado = 1
    var property tiempo = 0
    var property tiempoParaCocido = 0

    method image() = "panqueque_" + estado.toString() + ".png"

    method iniciar() {
        self.reiniciar()
        game.onTick(1000, "cocinar_" + id.toString(), { self.cocinar() })
    }

    method cocinar() {
        tiempo += 1
        
        // Pasa a cocido en su tiempo random
        if (tiempo == tiempoParaCocido) {
            estado = 2
        }
        
        // Margen de 2 segundos para sacarlo
        if (tiempo == tiempoParaCocido + 2) {
            estado = 3 // Se quema
        }
        
        // Si pasan 3 segundos quemado, se reinicia solo
        if (tiempo >= tiempoParaCocido + 5) {
            self.reiniciar()
        }
    }

    method reiniciar() {
        estado = 1
        tiempo = 0
        // Cada sartén elige un tiempo distinto para estar listo (entre 3 y 6 segundos)
        // Y un delay inicial negativo para que no empiecen todas a la vez
        tiempoParaCocido = (3 .. 6).anyOne()
        tiempo = - (1 .. 8).anyOne()
    }

    method detener() {
        try { game.removeTickEvent("cocinar_" + id.toString()) } catch e : Exception { return }
    }
}

// --- OBJETOS VISUALES ---
object notaReceta {
    method image() = "nota_" + minijuegoPanqueques.indiceReceta() + ".png"
    method position() = game.origin()
}

object selectorMezcla {
    var property position = game.at(3, 3)
    method image() = "selector.png"
}

object marcadorGeneral {
    method text() = "TIEMPO: " + minijuegoPanqueques.tiempoRestante() +
                    " | FASE: " + minijuegoPanqueques.faseActual() +
                    " | LISTOS: " + minijuegoPanqueques.panquequesListos() + "/12"
    method position() = game.at(2, 14)
    method textColor() = "FFFFFF"
}

object fondoCocinaPanqueques {
    var property image = "fondococina.png"
    method position() = game.origin()
}