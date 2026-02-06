import wollok.game.*
import inicio.*
import niveles.*
import nivelVisualStudio.*
import nivelCroquetas.*
import nivelMercadoLibre.*
import nivelTerraria.*
import nivelMerienda.*
import sonidos.*

class PantallaConFondo {
	var property imagenes = []
	var property musica = null
	var property onEnter = {  }
	var property onConfig = {  }
	var property position = game.origin()
	var property fotograma = 0
	const tick = 100

	method image() = if (!imagenes.isEmpty()) imagenes.get(fotograma) else ""

	method animar(){
		game.schedule(tick, { 
			fotograma = (fotograma + 1) % imagenes.size()
			self.animar()
		})
	}

	method config() {
		game.clear()
		if (!game.hasVisual(self)) {
			game.addVisual(self)
		}

		fotograma = 0
		if (musica != null) {
			sonido.reproducirMusica(new Ambiente(rutaArchivo = musica))
		}
		if (!imagenes.isEmpty()) {
			self.animar()
		}

		onConfig.apply()
		keyboard.enter().onPressDo({ onEnter.apply() })
	}
}

object pantallas {
	const property inicio = new PantallaConFondo(
		imagenes = ["portada1.png", "portada2.png"],
		musica = "musica_intro.mp3",
		onEnter = {
			sonido.ejecutar(creadorDeSonidos.start())
			self.controles().config()
		}
	)

	const property controles = new PantallaConFondo(
		imagenes = ["pantallainstruccion.png", "pantallainstruccion.png"],
		musica = "musica_intro.mp3",
		onEnter = {
			sonido.ejecutar(creadorDeSonidos.start())
			nivelHabitacion.config()
		}
	)

	const property instruccionCroquetas = new PantallaConFondo(
		imagenes = ["instrucciongato.png", "instrucciongato.png"],
		musica = "musica_gato.mp3",
		onEnter = { minijuegoCroquetas.config() }
	)

	const property instruccionMercado = new PantallaConFondo(
		imagenes = ["instruccionesmeli.png", "instruccionesmeli.png"],
		musica = "musica_fondo_habitacion.mp3",
		onEnter = { nivelCaptcha1.config() }
	)

	const property captchaSuperado = new PantallaConFondo(
		imagenes = ["pantallacaptchasuperado.png", "pantallacaptchasuperado.png"],
		onEnter = { nivelComputadoraV2.config() }
	)

	const property instruccionVS = new PantallaConFondo(
		imagenes = ["instruccionvs.png", "instruccionvs.png"],
		musica = "musica_vs.mp3",
		onEnter = { nivelVisualStudio.config() }
	)

	const property instruccionTerraria = new PantallaConFondo(
		imagenes = ["instruccionterraria.png", "instruccionterraria.png"],
		musica = "musica_terraria.mp3",
		onEnter = { nivelTerraria.config() }
	)

	const property instruccionMerienda = new PantallaConFondo(
		imagenes = ["instruccionespanqueques.png", "instruccionespanqueques.png"],
		musica = "musica_merienda.mp3",
		onEnter = { minijuegoPanqueques.config() }
	)

	const property fin = new PantallaConFondo(
		imagenes = ["pantallavictoria.png", "pantallavictoria2.png"],
		musica = "musica_fondo.mp3",
		onConfig = { sonido.ejecutar(creadorDeSonidos.victoria()) },
		onEnter = { self.inicio().config() }
	)
}
