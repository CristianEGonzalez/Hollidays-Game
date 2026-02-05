class Fondo{
  var property image = ""
  var property position = game.origin()
}

class FondoAnimado inherits Fondo{
  const imagenes = []
  const tick = 100
  var fotograma = 0

  override method image() = imagenes.get(fotograma)

  method animar(){
    game.schedule(tick, { 
      fotograma = (fotograma + 1) % imagenes.size()
      self.animar()
    })
  }
}