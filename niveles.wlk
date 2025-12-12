import personajes.*
import objetos.*


object nivelHabitacion {

  var property bloqueadores = [escritorio, silla, cama]

  method config() {
    game.clear()
    
    game.addVisual(fondoHabitacion)
    cris.initialize()
    game.addVisual(cris)

    bloqueadores.forEach{ b => game.addVisual(b) }

    self.configurarTeclado()
  }

  method configurarTeclado() {
    keyboard.up().onPressDo{ moverArriba.mover() }
    keyboard.down().onPressDo{ moverAbajo.mover() }
    keyboard.left().onPressDo{ moverIzquierda.mover() }
    keyboard.right().onPressDo{ moverDerecha.mover() }
  }
}

object fondoHabitacion {
  var property image = "pruebafondo.png"
  var property position = game.origin()
}