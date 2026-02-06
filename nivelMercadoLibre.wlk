import pantallas.*
import niveles.*
import personajes.*
import objetos.*
import thinIce.*
import fondos.*

object nivelMercadoLibre inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="mercadolibre1.png"))
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(4, 7), pantallas.instruccionMercado())
    self.agregarPortalEn(game.at(5, 7), pantallas.instruccionMercado())
  }

  override method musicaDeNivel() = "musica_fondo_habitacion.mp3"
}

object nivelMercadoLibre2 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="mercadolibre2.png"))
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(7, 7), nivelCaptcha2)
    self.agregarPortalEn(game.at(8, 7), nivelCaptcha2)
    self.agregarPortalEn(game.at(9, 7), nivelCaptcha2)
  }

  override method musicaDeNivel() = "musica_fondo_habitacion.mp3"
}

object nivelMercadoLibre3 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="mercadolibre3.png"))
  }
  
  override method configurarPortales() {
    // Portales para el minijuego captcha
    self.agregarPortalEn(game.at(11, 7), nivelCaptcha3)
    self.agregarPortalEn(game.at(12, 7), nivelCaptcha3)
  }

  override method musicaDeNivel() = "musica_fondo_habitacion.mp3"
}

class NivelCaptchaBase inherits NivelComputadoraBase {
  var property thinIceSystem = null
  var property fondo = null
  var property posInicio = null
  var property areaJuego = []
  var property siguienteNivel = null

  override method musicaDeNivel() = "musica_fondo_habitacion.mp3"

  override method agregarFondo() {
    game.addVisual(fondo)
  }

  override method configurarPersonaje() {
    cris.position(posInicio)
    cris.image("crispetit.png")
    
    thinIceSystem.posicionInicial(posInicio)
    thinIceSystem.inicializar()
    thinIceSystem.configurarAreaJuego(areaJuego)
  }

  override method configurarBloqueadores() {
    // Limpiar los visuales del motor antes de vaciar la lista
    bloqueadores.forEach({ b => game.removeVisual(b) })
    bloqueadores.clear()
    
    super()
    
    // Bloqueo de bordes
    (0..6).forEach({ f => self.agregarBloqueadorEn(game.at(0, f)) })
    (13..15).forEach({ f => self.agregarBloqueadorEn(game.at(0, f)) })

    // Bloqueo por área de juego
    areaJuego.forEach({ filaInfo =>
      const y = filaInfo.get(0)
      const permitidos = filaInfo.get(1)
      (0..15).forEach({ x =>
        if (!permitidos.contains(x)) self.agregarBloqueadorEn(game.at(x, y))
      })
    })
  }

  override method configurarTeclado() {
    keyboard.up().onPressDo({ self.intentarMover(cris.position().up(1)) })
    keyboard.down().onPressDo({ self.intentarMover(cris.position().down(1)) })
    keyboard.left().onPressDo({ self.intentarMover(cris.position().left(1)) })
    keyboard.right().onPressDo({ self.intentarMover(cris.position().right(1)) })
    keyboard.r().onPressDo({ self.reiniciarNivel() })
    keyboard.e().onPressDo({ self.procesarInteraccion() })
  }

  // Anulamos verificarColisiones para que no recorra la lista de bloqueadores una segunda vez innecesariamente
  override method verificarColisiones() { }

  method intentarMover(nuevaPos) {
    if (thinIceSystem.juegoTerminado()) {
      siguienteNivel.config()
    } 
    else if (!thinIceSystem.personajePerdio()) {
      const bloqueador = bloqueadores.findOrDefault({ b => b.position() == nuevaPos }, null)
      
      self.procesarMovimientoFisico(nuevaPos, bloqueador)
    }
  }

  method procesarMovimientoFisico(nuevaPos, bloqueador) {
    if (bloqueador != null) {
      cris.chocadoConBloqueador(bloqueador)
    } else {
      // Solo si NO hay bloqueador llamamos al sistema de Thin Ice
      const movValido = thinIceSystem.moverPersonaje(cris.position(), nuevaPos)
      if (movValido) {
        cris.position(nuevaPos)
        if (thinIceSystem.juegoTerminado()) siguienteNivel.config()
      } else if (thinIceSystem.personajePerdio()) {
        self.reiniciarNivel()
      }
    }
  }

  method reiniciarNivel() {
    thinIceSystem.reiniciar()
    cris.position(posInicio)
    cris.image("crispetit.png")
  }

  override method procesarInteraccion() {
    if (thinIceSystem.juegoTerminado()) siguienteNivel.config()
    else if (thinIceSystem.personajePerdio()) self.reiniciarNivel()
  }
}

object nivelCaptcha1 inherits NivelCaptchaBase(
  fondo = new Fondo(image="nivel1ice.png"),
  posInicio = game.at(2, 7),
  siguienteNivel = nivelMercadoLibre2,
  thinIceSystem = new ThinIceSystem(posicionMeta = game.at(13, 7), posicionInicial = posInicio),
  areaJuego = [
    [7, [2, 6, 7, 8, 9, 13]], [8, [2, 6, 7, 8, 9, 13]], [9, [2, 7, 8, 13]],
    [10, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]],
    [11, [1, 2, 3, 6, 7, 8, 9, 12, 13, 14]], [12, [1, 2, 3, 12, 13, 14]]
  ]
) {}

object nivelCaptcha2 inherits NivelCaptchaBase(
  fondo = new Fondo(image="nivel2ice.png"),
  posInicio = game.at(12, 12),
  siguienteNivel = nivelMercadoLibre3,
  thinIceSystem = new ThinIceSystem(posicionMeta = game.at(0, 9), posicionInicial = posInicio),
  areaJuego = [
    [8, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
    [9, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
    [10, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
    [11, [12]], [12, [12]]
  ]
) {}

object nivelCaptcha3 inherits NivelCaptchaBase(
  fondo = new Fondo(image="nivel3ice.png"),
  posInicio = game.at(0, 9),
  siguienteNivel = pantallas.captchaSuperado(),
  thinIceSystem = new ThinIceSystem(posicionMeta = game.at(12, 12), posicionInicial = posInicio),
  areaJuego = [
    [7, [5, 6, 7]], [8, [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]],
    [9, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14]],
    [10, [3, 4, 5, 7, 8, 9, 10, 12, 13, 14]], [11, [12]], [12, [12]]
  ]
) {}