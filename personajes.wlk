import niveles.*

object cris {
  var property image = "crisCharacter.png"
  var property position = game.at(11, 6)
  var property previousPosition = game.at(11, 6)
  
  method initialize() {
    image = "crisCharacter.png"
    position = game.at(11, 6)
    previousPosition = position
  }
  
  method compartePosicion(obj) = self.position() == obj.position()
  
  method chocadoConBloqueador(bloqueador) {
    if (self.compartePosicion(bloqueador)) // Revertir a la posición anterior
      self.position(previousPosition)
  }
}

class Mover {
  method move(newPosition) {
    cris.previousPosition(cris.position())
    cris.position(newPosition)
  }
  
  method config() {
    nivelHabitacion.bloqueadores().forEach(
      { bloqueador => cris.chocadoConBloqueador(bloqueador) }
    )
  }
}

object moverArriba inherits Mover {
  method mover() {
    cris.image("crisCharacter.png")
    self.move(cris.position().up(1))
    if (cris.position().y() == 15) cris.position(cris.position().down(1))
    
    self.config()
  }
}

object moverAbajo inherits Mover {
  method mover() {
    cris.image("crisCharacter.png")
    self.move(cris.position().down(1))
    if (cris.position().y() == (-1)) cris.position(cris.position().up(1))
    
    self.config()
  }
}

object moverDerecha inherits Mover {
  method mover() {
    cris.image("crisCharacter.png")
    self.move(cris.position().right(1))
    if (cris.position().x() == 15) cris.position(cris.position().left(1))
    
    self.config()
  }
}

object moverIzquierda inherits Mover {
  method mover() {
    cris.image("crisCharacter.png")
    self.move(cris.position().left(1))
    if (cris.position().x() == (-1)) cris.position(cris.position().right(1))
    
    self.config()
  }
}

object ali {
  var property image = "ali.png"
  var property position = game.at(10, 8)
}

object gatito {
  var property image = "gatito.png"
  var property position = game.at(12, 10)
}