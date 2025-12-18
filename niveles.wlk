import personajes.*
import objetos.*
import thinIce.*

class NivelBase {
  var property bloqueadores = []
  var property portales = []
  var property interactuables = []
  
  method config() {
    game.clear()
    
    self.agregarFondo()
    self.agregarElementos()
    
    game.addVisual(cris)
    
    self.agregarElementosVisuales()
    
    self.configurarTeclado()
  }
  
  method agregarFondo() {}
  
  method agregarElementos() {
    // Posición y configuración inicial del personaje
    self.configurarPersonaje()
    
    // Configurar elementos del nivel
    self.configurarPortales()
    self.configurarBloqueadores()
    self.configurarInteractuables()
  }
  
  method configurarPersonaje() {
    cris.initialize()
  }
  
  method configurarPortales() {}
  
  method configurarBloqueadores() {}
  
  method configurarInteractuables() {}
  
  method agregarElementosVisuales() {
    // Agregar bloqueadores
    bloqueadores.forEach({ b => game.addVisual(b) })
    
    // Agregar interactuables visibles
    interactuables.forEach(
      { i => if (i.image() != "transparente.png") game.addVisual(i) }
    )
  }
  
  method configurarTeclado() {
    // Configuración del teclado para mover el personaje
    keyboard.up().onPressDo(
      { 
        moverArriba.mover()
        return self.verificarColisiones()
      }
    )
    
    keyboard.down().onPressDo(
      { 
        moverAbajo.mover()
        return self.verificarColisiones()
      }
    )
    
    keyboard.left().onPressDo(
      { 
        moverIzquierda.mover()
        return self.verificarColisiones()
      }
    )
    
    keyboard.right().onPressDo(
      { 
        moverDerecha.mover()
        return self.verificarColisiones()
      }
    )
    
    // Tecla E para interacciones
    keyboard.e().onPressDo({ self.procesarInteraccion() })
  }
  
  method verificarColisiones() {
    bloqueadores.forEach(
      { bloqueador => cris.chocadoConBloqueador(bloqueador) }
    )
  }
  
  method procesarInteraccion() {
    // Verificar portales
    portales.forEach(
      { portal => if (cris.estaEnPosicion(portal.posicion())) portal.accion() }
    )
    
    // Verificar interactuables
    interactuables.forEach(
      { interactuable => if (cris.compartePosicion(
                             interactuable
                           ) && interactuable.puedeInteractuar())
                           interactuable.accion() }
    )
  }
  
  method agregarBloqueador(bloqueador) {
    bloqueadores.add(bloqueador)
  }
  
  method agregarPortal(portal) {
    portales.add(portal)
  }
  
  method agregarInteractuable(interactuable) {
    interactuables.add(interactuable)
  }
  
  method agregarFilaBloqueadora(fila) {
    (0 .. 15).forEach(
      { x => self.agregarBloqueador(
          new Bloqueador(position = game.at(x, fila))
        ) }
    )
  }
  
  method agregarBloqueadorEn(posicion) {
    self.agregarBloqueador(new Bloqueador(position = posicion))
  }
  
  method agregarPortalEn(posicion, destino) {
    self.agregarPortal(new Portal(posicion = posicion, nivelDestino = destino))
  }
  
  method agregarAreaBloqueada(xInicio, xFin, yInicio, yFin) {
    (xInicio .. xFin).forEach(
      { x => (yInicio .. yFin).forEach(
          { y => self.agregarBloqueadorEn(game.at(x, y)) }
        ) }
    )
  }
}

object nivelHabitacion inherits NivelBase {
  override method agregarFondo() {
    game.addVisual(fondoHabitacion)
  }
  
  override method configurarBloqueadores() {
    // Escritorio (parte superior)
    self.agregarAreaBloqueada(0, 4, 8, 8) // Fila 8, columnas 0-4
    
    // Esquina del escritorio
    self.agregarBloqueadorEn(game.at(5, 9))
    self.agregarBloqueadorEn(game.at(6, 9))
    
    // Resto del escritorio
    self.agregarAreaBloqueada(7, 12, 8, 8) // Fila 8, columnas 7-12
    self.agregarAreaBloqueada(13, 15, 9, 9) // Fila 9, columnas 13-15
    
    // Cama
    self.agregarAreaBloqueada(8, 15, 4, 4) // Columna 8-15, fila 4
    self.agregarAreaBloqueada(8, 8, 0, 4) // Columna 8, filas 0-4
    
    // Ali/silla
    self.agregarBloqueadorEn(game.at(0, 6))
    self.agregarBloqueadorEn(game.at(1, 6))
    self.agregarBloqueadorEn(game.at(2, 6))
    self.agregarBloqueadorEn(game.at(2, 7))
    
    // Gatito (área 2x2)
    self.agregarAreaBloqueada(3, 4, 2, 3)
  }
  
  override method configurarPortales() {
    // Portales para cambiar al nivel de computadora
    self.agregarPortalEn(game.at(5, 8), nivelComputadora)
    self.agregarPortalEn(game.at(6, 8), nivelComputadora)
  }
}

object fondoHabitacion {
  var property image = "fondopersonajes.png"
  var property position = game.origin()
}

// Clase base para niveles con fondo de computadora
class NivelComputadoraBase inherits NivelBase {
  var property filaSuperiorBloqueada = 3
  
  override method configurarPersonaje() {
    cris.position(game.at(8, 12))
    cris.image("crispetit.png")
  }
  
  override method configurarBloqueadores() {
    self.agregarFilaBloqueadora(filaSuperiorBloqueada)
  }
}

object nivelComputadora inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(fondoComputadora)
  }
  
  override method configurarPortales() {
    self.agregarPortalEn(game.at(1, 11), nivelMercadoLibre)
  }
}

object nivelMercadoLibre inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(mercadoLibre1)
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(4, 6), nivelCaptcha1)
    self.agregarPortalEn(game.at(5, 6), nivelCaptcha1)
  }
}

object fondoComputadora {
  var property image = "compufondo.png"
  var property position = game.origin()
}

object mercadoLibre1 {
  var property image = "mercadolibre1.png"
  var property position = game.origin()
}

object nivelCaptcha1 inherits NivelComputadoraBase {
  var property thinIceSystem = new ThinIceSystem(
    posicionInicial = game.at(2, 7),
    posicionMeta = game.at(13, 7)
  )
  
  override method agregarFondo() {
    game.addVisual(nivelCaptchaFondo1)
  }
  
  override method configurarPersonaje() {
    cris.position(game.at(2, 7))
    cris.image("crispetit.png")
    
    // Inicializar sistema Thin Ice
    thinIceSystem.inicializar()
    
    // Configurar área de juego con las coordenadas
    thinIceSystem.configurarAreaJuego(
      [
        [7, [2, 6, 7, 8, 9, 13]],
        [8, [2, 6, 7, 8, 9, 13]],
        [9, [2, 7, 8, 13]],
        [10, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]],
        [11, [1, 2, 3, 6, 7, 8, 9, 12, 13, 14]],
        [12, [1, 2, 3, 12, 13, 14]]
      ]
    )
  }
  
  override method configurarBloqueadores() {
    super()
    // Configurar bloqueadores según las coordenadas NO jugables
    self.configurarBloqueadoresThinIce()
  }
  
  method configurarBloqueadoresThinIce() {
    // Para las filas 6-12, bloquear lo que NO está en las coordenadas jugables
    // Fila 6: completamente bloqueada
    self.agregarFilaBloqueadora(6)
    
    (0 .. 15).forEach(
      { x => if (![2, 6, 7, 8, 9, 13].contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 7)
               ) }
    )
    
    (0 .. 15).forEach(
      { x => if (![2, 6, 7, 8, 9, 13].contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 8)
               ) }
    )
    
    (0 .. 15).forEach(
      { x => if (![2, 7, 8, 13].contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 9)
               ) }
    )
    
    
    // Fila 10: bloquear todo excepto [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    const permitidos10 = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    (0 .. 15).forEach(
      { x => if (!permitidos10.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 10)
               ) }
    )
    
    
    // Fila 11: bloquear todo excepto [1, 2, 3, 6, 7, 8, 9, 12, 13, 14]
    const permitidos11 = [1, 2, 3, 6, 7, 8, 9, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos11.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 11)
               ) }
    )
    
    
    // Fila 12: bloquear todo excepto [1, 2, 3, 12, 13, 14]
    const permitidos12 = [1, 2, 3, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos12.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 12)
               ) }
    )
    
    // Filas 13-15 completamente bloqueadas
    self.agregarFilaBloqueadora(13)
    self.agregarFilaBloqueadora(14)
    self.agregarFilaBloqueadora(15)
  }
  
  override method configurarTeclado() {
    self.configurarTecladoThinIce()
  }
  
  method configurarTecladoThinIce() {
    keyboard.up().onPressDo({ self.moverArribaThinIce() })
    keyboard.down().onPressDo({ self.moverAbajoThinIce() })
    keyboard.left().onPressDo({ self.moverIzquierdaThinIce() })
    keyboard.right().onPressDo({ self.moverDerechaThinIce() })
    
    keyboard.r().onPressDo({ self.reiniciarNivel() })
    
    keyboard.e().onPressDo({ self.procesarInteraccionThinIce() })
  }
  
  method reiniciarNivel() {
    thinIceSystem.reiniciar()
    cris.position(game.at(2, 7))
    cris.image("crispetit.png")
  }

  // a refactorizar los metodos de movimiento
  
  method moverArribaThinIce() {
    if ((!thinIceSystem.juegoTerminado()) && (!thinIceSystem.personajePerdio())) {
      const posicionAnterior = cris.position()
      const nuevaPosicion = cris.position().up(1)
      
      if (!self.hayBloqueadorEn(nuevaPosicion)) {
        const movimientoValido = thinIceSystem.moverPersonaje(
          posicionAnterior,
          nuevaPosicion
        )
        
        if (movimientoValido) {
          cris.position(nuevaPosicion)
        } else {
          if (thinIceSystem.personajePerdio())
            // REINICIO AUTOMÁTICO al pisar agua
            self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
        //si no es posición válida choca con bloqueador
      }
    } else {
      if (thinIceSystem.juegoTerminado()) // CAMBIO AUTOMÁTICO al ganar
        nivelMercadoLibre.config()
    }
  }
  
  method moverAbajoThinIce() {
    if ((!thinIceSystem.juegoTerminado()) && (!thinIceSystem.personajePerdio())) {
      const posicionAnterior = cris.position()
      const nuevaPosicion = cris.position().down(1)
      
      if (!self.hayBloqueadorEn(nuevaPosicion)) {
        const movimientoValido = thinIceSystem.moverPersonaje(
          posicionAnterior,
          nuevaPosicion
        )
        
        if (movimientoValido) {
          cris.position(nuevaPosicion)
        } else {
          if (thinIceSystem.personajePerdio())
            self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado())
        nivelMercadoLibre.config()
    }
  }
  
  method moverIzquierdaThinIce() {
    if ((!thinIceSystem.juegoTerminado()) && (!thinIceSystem.personajePerdio())) {
      const posicionAnterior = cris.position()
      const nuevaPosicion = cris.position().left(1)
      
      if (!self.hayBloqueadorEn(nuevaPosicion)) {
        const movimientoValido = thinIceSystem.moverPersonaje(
          posicionAnterior,
          nuevaPosicion
        )
        
        if (movimientoValido) {
          cris.position(nuevaPosicion)
        } else {
          if (thinIceSystem.personajePerdio())
            self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado())
        nivelMercadoLibre.config()
    }
  }
  
  method moverDerechaThinIce() {
    if ((!thinIceSystem.juegoTerminado()) && (!thinIceSystem.personajePerdio())) {
      const posicionAnterior = cris.position()
      const nuevaPosicion = cris.position().right(1)
      
      if (!self.hayBloqueadorEn(nuevaPosicion)) {
        const movimientoValido = thinIceSystem.moverPersonaje(
          posicionAnterior,
          nuevaPosicion
        )
        
        if (movimientoValido) {
          cris.position(nuevaPosicion)
        } else {
          if (thinIceSystem.personajePerdio())
            self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado())
        nivelMercadoLibre.config()
    }
  }
  
  method hayBloqueadorEn(posicion) = bloqueadores.any(
    { b => b.position() == posicion }
  )
  
  method procesarInteraccionThinIce() {
    // Si el juego está terminado, ir a MercadoLibre2 (a hacer)
    if (thinIceSystem.juegoTerminado()) {
      nivelMercadoLibre.config()
    } else {
      if (thinIceSystem.personajePerdio()) // Si perdió, reiniciar
        self.reiniciarNivel()
    }
  }
  
  override method procesarInteraccion() {
    self.procesarInteraccionThinIce()
  }
}

object nivelCaptchaFondo1 {
  var property image = "nivel1hielo.png"
  var property position = game.origin()
}