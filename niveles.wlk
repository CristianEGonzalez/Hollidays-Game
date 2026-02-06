import nivelVisualStudio.*
import personajes.*
import objetos.*
import thinIce.*
import nivelMercadoLibre.*
import nivelTerraria.*
import nivelCroquetas.*
import nivelMerienda.*
import pantallas.*
import sonidos.*
import fondos.*

class NivelBase {
  var property bloqueadores = []
  var property portales = []
  var property interactuables = []
  
  method config() {
    game.clear()
    
    bloqueadores = []
    portales = []
    interactuables = []
    
    self.agregarFondo()
    self.agregarElementos()
    
    game.addVisual(cris)
    
    self.agregarElementosVisuales()
    
    self.configurarTeclado()

    sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
  }

  method musicaDeNivel() = "musica_intro.mp3"
  
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
      { i => game.addVisual(i) }
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
    
    // Tecla E para interacciones (abre/cierra diálogos)
    keyboard.e().onPressDo({ self.procesarInteraccion() })
  }
  
  method verificarColisiones() {
    bloqueadores.forEach(
      { bloqueador => cris.chocadoConBloqueador(bloqueador) }
    )
  }
  
  method procesarInteraccion() {
    if (game.hasVisual(pantallaDialogo)) {
      self.cerrarDialogo()
    } else {
      // Verificar portales
      portales.forEach(
        { portal => if (cris.estaEnPosicion(portal.posicion())) portal.accion() }
      )
      
      // Verificar interactuables
      if (interactuables.any({i => i.enAreaDeInteraccion()})) {
        const interactuableCerca = interactuables.find({i => i.enAreaDeInteraccion()})
        if (interactuableCerca.puedeInteractuar()) interactuableCerca.accion()
      }
    }

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

  override method configurarInteractuables() {
    ali.configurarHabitacionNormal()
    self.agregarInteractuable(ali)
    self.agregarInteractuable(gatito)
    self.agregarInteractuable(pizarron)
  }

  override method musicaDeNivel() = "musica_fondo.mp3"
}

object nivelHabitacion inherits NivelHabitacionBase {
  override method agregarFondo() { game.addVisual(new Fondo(image="fondohabitacion.png")) }
  override method configurarPortales() {
    self.agregarPortalEn(game.at(0, 1), pantallas.instruccionCroquetas())
    self.agregarPortalEn(game.at(1, 1), pantallas.instruccionCroquetas())
  }
}

object nivelHabitacionV2 inherits NivelHabitacionBase {
  override method agregarFondo() { game.addVisual(new Fondo(image="fondohabitacionV2.png")) }
  override method configurarPortales() {
    self.agregarPortalEn(game.at(5, 8), nivelComputadora)
    self.agregarPortalEn(game.at(6, 8), nivelComputadora)
  }
  override method configurarInteractuables() {
    super()
    ali.cambiarDialogos(["dialogoali1v2.png", "dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"])
}
}

object nivelHabitacionV3 inherits NivelHabitacionBase {
  override method agregarFondo() {
    const fondoV2 = new FondoAnimado(imagenes=["fondohabitacionV2_2.png", "fondohabitacionV2.png"], tick=500)
    game.addVisual(fondoV2)
    fondoV2.animar()
  }


  override method configurarPortales() {
    self.agregarPortalEn(game.at(14, 6), pantallas.instruccionMerienda())
  }
  override method configurarInteractuables() {
    super()
    ali.cambiarDialogos(["dialogoali1.png", "dialogoali2.png", "dialogoali3.png", "dialogoali4.png"])
}
}

object nivelHabitacionV4 inherits NivelBase {
  override method agregarFondo() {
    const fondoPanques = new FondoAnimado(imagenes=["fondowinpanqueque1.png","fondowinpanqueque2.png"], tick=500)
    game.addVisual(fondoPanques)
    fondoPanques.animar()
  }
  override method configurarPortales() {
    self.agregarPortalEn(game.at(0, 0), nivelRuta)
    self.agregarPortalEn(game.at(1, 0), nivelRuta)
  }

  override method musicaDeNivel() = "musica_fondo.mp3"

  override method retroceder() {
        self.cerrarDialogo()
    }

  override method configurarInteractuables() {
    ali.configurarMerienda()
    self.agregarInteractuable(ali)
  }

    override method config() {
        super()
        cris.position(game.at(12, 5))
    }

    override method configurarBloqueadores() {
        (0..11).forEach({ x => self.agregarBloqueadorEn(game.at(x, 4)) })
        [13, 14, 15].forEach({ x => self.agregarBloqueadorEn(game.at(x, 4)) })

        [10, 11, 13, 14, 15].forEach({ x => self.agregarBloqueadorEn(game.at(x, 5)) })

        (10..15).forEach({ x => self.agregarBloqueadorEn(game.at(x, 6)) })
    }
}

object nivelRuta inherits NivelBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="fondoruta.png"))
  }
  
  override method configurarPortales() {
    self.agregarPortalEn(game.at(14, 3), pantallas.fin())
    self.agregarPortalEn(game.at(14, 4), pantallas.fin())
    self.agregarPortalEn(game.at(14, 5), pantallas.fin())
    self.agregarPortalEn(game.at(14, 6), pantallas.fin())
    self.agregarPortalEn(game.at(14, 7), pantallas.fin())

    self.agregarPortalEn(game.at(15, 3), pantallas.fin())
    self.agregarPortalEn(game.at(15, 4), pantallas.fin())
    self.agregarPortalEn(game.at(15, 5), pantallas.fin())
    self.agregarPortalEn(game.at(15, 6), pantallas.fin())
    self.agregarPortalEn(game.at(15, 7), pantallas.fin())

  }

  override method config() {
      super()
      cris.position(game.at(0, 5))
      cris.image("auto.png")
  }

      override method configurarBloqueadores() {
        (0..15).forEach({ x => self.agregarBloqueadorEn(game.at(x, 2)) })

        (0..15).forEach({ x => self.agregarBloqueadorEn(game.at(x, 7)) })
    }

  override method musicaDeNivel() = "musica_fondo.mp3"
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

  override method musicaDeNivel() = "musica_fondo.mp3"
}

object nivelComputadora inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="compufondo.png"))
  }
  
  override method configurarPortales() {
    self.agregarPortalEn(game.at(1, 11), nivelMercadoLibre)
  }
}


object nivelComputadoraV2 inherits NivelComputadoraBase {
  override method agregarFondo() {
    game.addVisual(new Fondo(image="compufondo.png"))
  }
  
  override method configurarPortales() {
    self.agregarPortalEn(game.at(1, 9), pantallas.instruccionVS())
  }
}

object nivelComputadoraV3 inherits NivelComputadoraBase {
    override method agregarFondo() {
        game.addVisual(new Fondo(image="fondocompusalida.png"))
    }

    override method configurarPortales() {
        // Portal a Terraria
        self.agregarPortalEn(game.at(1, 7), pantallas.instruccionTerraria())
        
        // Portal de salida a la Habitación
        self.agregarPortalEn(game.at(14, 13), nivelHabitacionV3)
    }
}