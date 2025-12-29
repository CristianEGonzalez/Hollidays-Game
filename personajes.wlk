import niveles.*

object cris {
  var property image = "crisCharacter.png"
  var property position = game.at(11, 6)
  var property previousPosition = position
  
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

  method estaEnPosicion(pos) = self.position() == pos
}

class Mover {
  method move(newPosition) {
    cris.previousPosition(cris.position())
    cris.position(newPosition)
  }
  
  method config() {
  }
}

object moverArriba inherits Mover {
  method mover() {
    //cris.image("crisCharacter.png")
    self.move(cris.position().up(1))
    if (cris.position().y() == 15) cris.position(cris.position().down(1))
    
  }
}

object moverAbajo inherits Mover {
  method mover() {
    //cris.image("crisCharacter.png")
    self.move(cris.position().down(1))
    if (cris.position().y() == (-1)) cris.position(cris.position().up(1))

  }
}

object moverDerecha inherits Mover {
  method mover() {
    //cris.image("crisCharacter.png")
    self.move(cris.position().right(1))
    if (cris.position().x() == 15) cris.position(cris.position().left(1))

  }
}

object moverIzquierda inherits Mover {
  method mover() {
    //cris.image("crisCharacter.png")
    self.move(cris.position().left(1))
    if (cris.position().x() == (-1)) cris.position(cris.position().right(1))

  }
}
