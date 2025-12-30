import personajes.*

class ThinIceSystem {
  var property posicionesAgua = []
  // Guardamos los objetos AguaVisual en una lista enves de game.allVisuals() que es lento.
  var property visualesAgua = []
  var property posicionInicial
  var property posicionMeta
  var property areaJuego = []
  var property juegoTerminado = false
  var property personajePerdio = false
  
  method inicializar() {
    posicionesAgua = []
    visualesAgua = []
    juegoTerminado = false
    personajePerdio = false
  }
  
  method configurarAreaJuego(coordenadas) {
    areaJuego = []
    coordenadas.forEach(
      { config =>
        const fila = config.get(0)
        const columnas = config.get(1)
        return columnas.forEach(
          { columna => areaJuego.add(game.at(columna, fila)) }
        )
      }
    )
  }
  
  method esPosicionJugable(posicion) = areaJuego.any({ p => p == posicion })
  
  method agregarAgua(posicion) {
    const puedeAgregar = (!self.tieneAguaEn(
      posicion
    )) && self.esPosicionJugable(posicion)
    
    if (puedeAgregar) {
      posicionesAgua.add(posicion)
      self.actualizarVisual(posicion)
    }
    
    return puedeAgregar
  }
  
  method tieneAguaEn(posicion) = posicionesAgua.any({ p => p == posicion })
  
  method moverPersonaje(posicionAnterior, nuevaPosicion) {
    if (juegoTerminado || personajePerdio) {
      return false
    }
    
    // Verificar si la nueva posición es jugable
    if (!self.esPosicionJugable(nuevaPosicion)) {
      return false
    }
    
    // Si cae en agua, pierde
    if (self.tieneAguaEn(nuevaPosicion)) {
      personajePerdio = true
      return false
    }
    
    // Agregar agua en la posición anterior (excepto si es meta)
    if ((posicionAnterior != posicionMeta) && (!self.tieneAguaEn(
        posicionAnterior
      ))) self.agregarAgua(posicionAnterior)
    
    // Verificar si llegó a la meta
    return if (nuevaPosicion == posicionMeta) self.verificarVictoria() else true
  }
  
  method verificarVictoria() {
    // Contar cuántas posiciones jugables deben tener agua
    // (todas excepto la meta)
    const posicionesParaAgua = areaJuego.filter({ p => p != posicionMeta })
    
    const todasConAgua = posicionesParaAgua.all({ p => self.tieneAguaEn(p) })
    
    if (todasConAgua) {
      juegoTerminado = true
    }
    
    const resultado = juegoTerminado
    
    return resultado
  }
  
  method reiniciar() {
    visualesAgua.forEach({ visual => game.removeVisual(visual) })
    
    visualesAgua = []
    posicionesAgua = []
    juegoTerminado = false
    personajePerdio = false
    cris.position(posicionInicial)
  }
  
  method actualizarVisual(posicion) {
    const agua = new AguaVisual(position = posicion)
    visualesAgua.add(agua)
    game.addVisual(agua)
  }
  
  method obtenerVisualAgua(posicion) {
    const todosVisuales = game.allVisuals()
    return todosVisuales.find(
      { visual =>
        (visual.image() == "agua.png") && (visual.position() == posicion) }
    )
  }
}

class AguaVisual {
  var property image = "agua.png"
  var property position
  
  override method ==(otro) {
    if (otro == null) {
      return false
    }
    return self.position() == otro.position()
  }
}