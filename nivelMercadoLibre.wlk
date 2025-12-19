import niveles.*
import personajes.*
import objetos.*
import thinIce.*

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

object nivelMercadoLibre2 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(mercadoLibre2)
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(7, 6), nivelCaptcha2)
    self.agregarPortalEn(game.at(8, 6), nivelCaptcha2)
    self.agregarPortalEn(game.at(9, 6), nivelCaptcha2)
  }
}

object nivelMercadoLibre3 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(mercadoLibre3)
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(10, 6), nivelCaptcha3)
    self.agregarPortalEn(game.at(11, 6), nivelCaptcha3)
  }
}

object mercadoLibre1 {
  var property image = "mercadolibre1.png"
  var property position = game.origin()
}

object mercadoLibre2 {
  var property image = "mercadolibre2.png"
  var property position = game.origin()
}

object mercadoLibre3 {
  var property image = "mercadolibre3.png"
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
      }
    } else {
      if (thinIceSystem.juegoTerminado()) // CAMBIO AUTOMÁTICO al ganar
        nivelMercadoLibre2.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre2.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre2.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre2.config()
    }
  }
  
  method hayBloqueadorEn(posicion) = bloqueadores.any(
    { b => b.position() == posicion }
  )
  
  method procesarInteraccionThinIce() {
    // Si el juego está terminado, ir a MercadoLibre2 (a hacer)
    if (thinIceSystem.juegoTerminado()) {
      nivelMercadoLibre2.config()
    } else {
      if (thinIceSystem.personajePerdio()) // Si perdió, reiniciar
        self.reiniciarNivel()
    }
  }
  
  override method procesarInteraccion() {
    self.procesarInteraccionThinIce()
  }
}

object nivelCaptcha2 inherits NivelComputadoraBase {
  var property thinIceSystem = new ThinIceSystem(
    posicionInicial = game.at(12, 12),
    // Empieza en (12, 12)
    posicionMeta = game.at(0, 9) // Meta en (0, 9)
  )
  
  override method agregarFondo() {
    game.addVisual(nivelCaptchaFondo2)
  }
  
  override method configurarPersonaje() {
    cris.position(game.at(12, 12))
    cris.image("crispetit.png")
    
    // Inicializar sistema Thin Ice
    thinIceSystem.inicializar()
    
    thinIceSystem.configurarAreaJuego(
      [
        [8, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
        [9, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
        [10, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
        [11, [12]],
        [12, [12]]
      ]
    )
  }
  
  override method configurarBloqueadores() {
    super()
    // Configurar bloqueadores según las coordenadas NO jugables
    self.configurarBloqueadoresThinIce()
  }
  
  method configurarBloqueadoresThinIce() {
    // Fila 6 y 7 completamente bloqueadas (fuera del área de juego)
    self.agregarFilaBloqueadora(6)
    self.agregarFilaBloqueadora(7)
    
    
    // Fila 8: bloquear todo excepto [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    const permitidos8 = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos8.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 8)
               ) }
    )
    
    
    // Fila 9: bloquear todo excepto [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    const permitidos9 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos9.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 9)
               ) }
    )
    
    
    // Fila 10: bloquear todo excepto [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    const permitidos10 = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos10.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 10)
               ) }
    )
    
    
    (0 .. 15).forEach(
      { x => if (x != 12) self.agregarBloqueadorEn(game.at(x, 11)) }
    )
    
    
    (0 .. 15).forEach(
      { x => if (x != 12) self.agregarBloqueadorEn(game.at(x, 12)) }
    )
    
    // Filas 13-15 completamente bloqueadas
    self.agregarFilaBloqueadora(13)
    self.agregarFilaBloqueadora(14)
    self.agregarFilaBloqueadora(15)
    
    
    (0 .. 5).forEach({ fila => self.agregarFilaBloqueadora(fila) })
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
    cris.position(game.at(12, 12))
    cris.image("crispetit.png")
  }
  
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre3.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre3.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre3.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelMercadoLibre3.config()
    }
  }
  
  method hayBloqueadorEn(posicion) = bloqueadores.any(
    { b => b.position() == posicion }
  )
  
  method procesarInteraccionThinIce() {
    if (thinIceSystem.juegoTerminado()) {
      nivelMercadoLibre3.config()
    } else {
      if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
    }
  }
  
  override method procesarInteraccion() {
    self.procesarInteraccionThinIce()
  }
}

object nivelCaptcha3 inherits NivelComputadoraBase {
  var property thinIceSystem = new ThinIceSystem(
    posicionInicial = game.at(0, 9),
    // Empieza en (0, 9)
    posicionMeta = game.at(12, 12) // Meta en (12, 12)
  )
  
  override method agregarFondo() {
    game.addVisual(nivelCaptchaFondo3)
  }
  
  override method configurarPersonaje() {
    cris.position(game.at(0, 9))
    cris.image("crispetit.png")
    
    // Inicializar sistema Thin Ice
    thinIceSystem.inicializar()
    
    thinIceSystem.configurarAreaJuego(
      [
        [7, [5, 6, 7]],
        [8, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
        [9, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]],
        [10, [3, 4, 5, 7, 8, 9, 10, 12, 13, 14]],
        [11, [12]],
        [12, [12]]
      ]
    )
  }
  
  override method configurarBloqueadores() {
    super()
    // Configurar bloqueadores según las coordenadas NO jugables
    self.configurarBloqueadoresThinIce()
  }
  
  method configurarBloqueadoresThinIce() {
    // Fila 6 completamente bloqueada (fuera del área de juego)
    self.agregarFilaBloqueadora(6)
    
    
    (0 .. 15).forEach(
      { x => if (![5, 6, 7].contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 7)
               ) }
    )
    
    
    // Fila 8: bloquear todo excepto [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    const permitidos8 = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos8.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 8)
               ) }
    )
    
    
    // Fila 9: bloquear todo excepto [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]
    const permitidos9 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos9.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 9)
               ) }
    )
    
    
    // Fila 10: bloquear todo excepto [3, 4, 5, 7, 8, 9, 10, 12, 13, 14]
    const permitidos10 = [3, 4, 5, 7, 8, 9, 10, 12, 13, 14]
    (0 .. 15).forEach(
      { x => if (!permitidos10.contains(x)) self.agregarBloqueadorEn(
                 game.at(x, 10)
               ) }
    )
    
    
    (0 .. 15).forEach(
      { x => if (x != 12) self.agregarBloqueadorEn(game.at(x, 11)) }
    )
    
    
    (0 .. 15).forEach(
      { x => if (x != 12) self.agregarBloqueadorEn(game.at(x, 12)) }
    )
    
    // Filas 13-15 completamente bloqueadas
    self.agregarFilaBloqueadora(13)
    self.agregarFilaBloqueadora(14)
    self.agregarFilaBloqueadora(15)
    
    
    (0 .. 5).forEach({ fila => self.agregarFilaBloqueadora(fila) })
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
    cris.position(game.at(0, 9))
    cris.image("crispetit.png")
  }
  
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelComputadoraV2.config()
        // Nivel 3 lleva a nivelComputadora por ahora
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelComputadoraV2.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelComputadoraV2.config()
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
          if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
        }
      } else {
        cris.chocadoConBloqueador(new Bloqueador(position = nuevaPosicion))
      }
    } else {
      if (thinIceSystem.juegoTerminado()) nivelComputadoraV2.config()
    }
  }
  
  method hayBloqueadorEn(posicion) = bloqueadores.any(
    { b => b.position() == posicion }
  )
  
  method procesarInteraccionThinIce() {
    if (thinIceSystem.juegoTerminado()) {
      nivelComputadoraV2.config()
    } else {
      if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
    }
  }
  
  override method procesarInteraccion() {
    self.procesarInteraccionThinIce()
  }
}

object nivelCaptchaFondo1 {
  var property image = "nivel1ice.png"
  var property position = game.origin()
}

object nivelCaptchaFondo2 {
  var property image = "nivel2ice.png"
  var property position = game.origin()
}

object nivelCaptchaFondo3 {
  var property image = "nivel3ice.png"
  var property position = game.origin()
}