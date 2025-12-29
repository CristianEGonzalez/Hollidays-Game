import nivelVisualStudio.*
import personajes.*
import objetos.*
import thinIce.*
import nivelMercadoLibre.*
import nivelTerraria.*
import nivelCroquetas.*
import nivelMerienda.*
import inicio.*
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
  
  method agregarFondo() {
    
  }
  
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
  
  method configurarPortales() {
    
  }
  
  method configurarBloqueadores() {
    
  }
  
  method configurarInteractuables() {
    
  }
  
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

    keyboard.b().onPressDo({ self.retroceder() })
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

  method retroceder() {}

  method cerrarDialogo() {
    if (game.hasVisual(pantallaDialogo)) {
        game.removeVisual(pantallaDialogo)
    }
  }
}

class NivelHabitacionBase inherits NivelBase {
  override method retroceder() { self.cerrarDialogo() }

  override method configurarBloqueadores() {
    self.agregarAreaBloqueada(0, 4, 8, 8)
    self.agregarBloqueadorEn(game.at(5, 9))
    self.agregarBloqueadorEn(game.at(6, 9))
    self.agregarAreaBloqueada(7, 12, 8, 8)
    self.agregarAreaBloqueada(13, 15, 9, 9)
    self.agregarAreaBloqueada(8, 15, 4, 4)
    self.agregarAreaBloqueada(8, 8, 0, 4)
    self.agregarBloqueadorEn(game.at(0, 6))
    self.agregarBloqueadorEn(game.at(1, 6))
    self.agregarBloqueadorEn(game.at(2, 6))
    self.agregarBloqueadorEn(game.at(2, 7))
    self.agregarAreaBloqueada(3, 4, 2, 3)
    self.agregarBloqueadorEn(game.at(0, 0))
    self.agregarBloqueadorEn(game.at(1, 0))
    self.agregarBloqueadorEn(game.at(2, 0))
  }

  method elGatito() 

  override method configurarInteractuables() {
    self.agregarInteractuable(ali)
    self.agregarInteractuable(self.elGatito())
    self.agregarInteractuable(pizarron)
    
    self.agregarInteractuable(new InteractuableInvisible(position = game.at(4,1), objetivo = self.elGatito()))
    self.agregarInteractuable(new InteractuableInvisible(position = game.at(5,2), objetivo = self.elGatito()))
    self.agregarInteractuable(new InteractuableInvisible(position = game.at(2,2), objetivo = self.elGatito()))
    self.agregarInteractuable(new InteractuableInvisible(position = game.at(13, 8), objetivo = pizarron))
  }
}

object nivelHabitacion inherits NivelHabitacionBase {
  override method elGatito() = gatito
  override method agregarFondo() { game.addVisual(fondoHabitacion) }
  override method configurarPortales() {
    self.agregarPortalEn(game.at(0, 1), pantallaInstruccionCroquetas)
    self.agregarPortalEn(game.at(1, 1), pantallaInstruccionCroquetas)
  }
}

object nivelHabitacionV2 inherits NivelHabitacionBase {
  override method elGatito() = gatito2
  override method agregarFondo() { game.addVisual(fondoHabitacionV2) }
  override method configurarPortales() {
    self.agregarPortalEn(game.at(5, 8), nivelComputadora)
    self.agregarPortalEn(game.at(6, 8), nivelComputadora)
  }
  override method configurarInteractuables() {
    super()
    ali.cambiarDialogos(["dialogoali1v2.png", "dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"])
}
}


class InteractuableInvisible inherits Interactuable {
    var property objetivo
    override method image() = "transparente.png"
    override method accion() { objetivo.accion() }
}

object fondoHabitacion {
  var property image = "fondohabitacion.png"
  var property position = game.origin()
}

object fondoHabitacionV2 {
  var property image = "fondohabitacionV2.png"
  var property position = game.origin()
}

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

object fondoComputadora {
  var property image = "compufondo.png"
  var property position = game.origin()
}

object nivelComputadoraV2 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(fondoComputadora)
  }
  
  override method configurarPortales() {
    self.agregarPortalEn(game.at(1, 9), nivelVisualStudio)
  }
}

object nivelComputadoraV3 inherits NivelComputadoraBase {
    override method agregarFondo() {
        game.addVisual(fondoComputadora)
    }

    override method configurarPortales() {
        // Portal a Terraria
        self.agregarPortalEn(game.at(1, 7), nivelTerraria)
        
        // Portal de salida a la Habitación
        self.agregarPortalEn(game.at(14, 14), nivelHabitacion)
    }
}