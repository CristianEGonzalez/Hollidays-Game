import personajes.*
import objetos.*

object nivelHabitacion {
  var property bloqueadores = [
    //escritorio
    new Bloqueador(position = game.at(0, 8)),
    new Bloqueador(position = game.at(1, 8)),
    new Bloqueador(position = game.at(2, 8)),
    new Bloqueador(position = game.at(3, 8)),
    new Bloqueador(position = game.at(4, 8)),
    new Bloqueador(position = game.at(5, 9)),
    new Bloqueador(position = game.at(6, 9)),
    new Bloqueador(position = game.at(7, 8)),
    new Bloqueador(position = game.at(8, 8)),
    new Bloqueador(position = game.at(9, 8)),
    new Bloqueador(position = game.at(10, 8)),
    new Bloqueador(position = game.at(11, 8)),
    new Bloqueador(position = game.at(12, 8)),
    new Bloqueador(position = game.at(13, 9)),
    new Bloqueador(position = game.at(14, 9)),
    new Bloqueador(position = game.at(15, 9)),
    //cama
    new Bloqueador(position = game.at(15, 4)),
    new Bloqueador(position = game.at(14, 4)),
    new Bloqueador(position = game.at(13, 4)),
    new Bloqueador(position = game.at(12, 4)),
    new Bloqueador(position = game.at(11, 4)),
    new Bloqueador(position = game.at(10, 4)),
    new Bloqueador(position = game.at(9, 4)),
    new Bloqueador(position = game.at(8, 4)),
    new Bloqueador(position = game.at(8, 3)),
    new Bloqueador(position = game.at(8, 2)),
    new Bloqueador(position = game.at(8, 1)),
    new Bloqueador(position = game.at(8, 0)),
    //ali/silla
    new Bloqueador(position = game.at(0, 6)),
    new Bloqueador(position = game.at(1, 6)),
    new Bloqueador(position = game.at(2, 6)),
    new Bloqueador(position = game.at(2, 7)),
    //gatito
    new Bloqueador(position = game.at(3, 2)),
    new Bloqueador(position = game.at(4, 2)),
    new Bloqueador(position = game.at(3, 3)),
    new Bloqueador(position = game.at(4, 3))
  ]
  const property portales = [
    new Portal(posicion = game.at(5, 8), nivelDestino = nivelComputadora),
    new Portal(posicion = game.at(6, 8), nivelDestino = nivelComputadora)
  ]
  var property interactuables = []
  
  method config() {
    game.clear()
    
    game.addVisual(fondoHabitacion)
    cris.initialize()
    game.addVisual(cris)
    
    bloqueadores.forEach({ b => game.addVisual(b) })
    
    interactuables.forEach(
      { i => if (i.image() != "transparente.png") game.addVisual(i) }
    )
    
    self.configurarTeclado()
  }
  
  method configurarTeclado() {
    // Movimientos
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
    keyboard.e().onPressDo(
      { 
        self.procesarInteraccion()
        return self.verificarColisiones()
      }
    )
  }
  
  method verificarColisiones() {
    bloqueadores.forEach(
      { bloqueador => cris.chocadoConBloqueador(bloqueador) }
    )
  }
  
  method procesarInteraccion() {
    portales.forEach(
      { portal => if (cris.estaEnPosicion(portal.posicion())) portal.accion() }
    )
    
    interactuables.forEach(
      { interactuable => if (cris.compartePosicion(
                             interactuable
                           ) && interactuable.puedeInteractuar())
                           interactuable.accion() }
    )
  }
}

object fondoHabitacion {
  var property image = "fondopersonajes.png"
  var property position = game.origin()
} // A refactorizar en una clase nivel

object nivelComputadora {
  var property bloqueadores = []
  var property interactuables = []
  var property portales = [
    new Portal(posicion = game.at(8, 12), nivelDestino = nivelHabitacion)
  ]
  
  method config() {
    game.clear()
    
    game.addVisual(fondoComputadora)

    cris.position(game.at(8, 12))
    cris.image("crispetit.png")
    game.addVisual(cris)
    
    self.configurarTeclado()
  }
  
  method configurarTeclado() {
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
    
    keyboard.e().onPressDo({ self.procesarInteraccion() })
  }
  
  method verificarColisiones() {
    bloqueadores.forEach(
      { bloqueador => cris.chocadoConBloqueador(bloqueador) }
    )
  }
  
  method procesarInteraccion() {
    portales.forEach(
      { portal => if (cris.estaEnPosicion(portal.posicion())) portal.accion() }
    )
    interactuables.forEach(
      { interactuable => if (cris.compartePosicion(
                             interactuable
                           ) && interactuable.puedeInteractuar())
                           interactuable.accion() }
    )
  }
}

object fondoComputadora {
  var property image = "compu.png"
  var property position = game.origin()
}