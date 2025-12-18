import personajes.*

class ThinIceSystem {
  var property posicionesAgua = []
  var property posicionInicial
  var property posicionMeta
  var property areaJuego = [] // Todas las posiciones jugables
  var property juegoTerminado = false
  var property personajePerdio = false
  
  method inicializar() {
    posicionesAgua = []
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
    
    
    // Si cae en agua, pierde (excepto si es la posición inicial)
    if (self.tieneAguaEn(nuevaPosicion) && (nuevaPosicion != posicionInicial)) {
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
    // Eliminar todas las imágenes de agua
    const visualesAEliminar = []
    posicionesAgua.forEach(
      { posicion =>
        const visualAgua = self.obtenerVisualAgua(posicion)
        if (visualAgua != null) visualesAEliminar.add(visualAgua)
      }
    )
    
    // Eliminar los visuales
    visualesAEliminar.forEach({ visual => game.removeVisual(visual) })
    
    posicionesAgua = []
    juegoTerminado = false
    personajePerdio = false // Volver personaje a posición inicial
    cris.position(posicionInicial)
  }
  
  method actualizarVisual(posicion) {
    const agua = new AguaVisual(position = posicion)
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