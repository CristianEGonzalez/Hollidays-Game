import nivelVisualStudio.*
import wollok.game.*
import niveles.*
import objetos.*
import nivelCroquetas.*
import nivelMercadoLibre.*
import sonidos.*
import nivelTerraria.*
import nivelMerienda.*
object comienzo {
	method config() {
		game.title("Our Love Story: The Next Patch")
		game.height(16)
		game.width(16)
		game.cellSize(50)
		game.addVisual(pantallaInicio)
		pantallaInicio.config()
	}
}

class Pantalla {
	var property position = game.origin()
	var fotograma = false
	const fotogramas = []

	method image() = if (fotograma) fotogramas.get(1) else fotogramas.get(0)

	method cambiarFotograma(){
		fotograma = !fotograma
	}

	method config() {
		game.clear()
		if(not game.hasVisual(self)){
			game.addVisual(self)
		}

		self.agregarFotograma()

		game.onTick(100, "cambiarFotograma", {self.cambiarFotograma()})
	}

	method configuracionAdicional(){}

	method agregarFotograma(){}
}

object pantallaInicio inherits Pantalla{
	override method agregarFotograma(){
		fotogramas.add("portada1.png")
		fotogramas.add("portada2.png")
	}

	method musicaDeNivel() = "musica_intro.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
		keyboard.enter().onPressDo{
			sonido.ejecutar(creadorDeSonidos.start())
			pantallaControles.config()
		}
	}

}

object pantallaControles inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("pantallainstruccion.png")
		fotogramas.add("pantallainstruccion.png")
	}

	method musicaDeNivel() = "musica_intro.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
		keyboard.enter().onPressDo{
			sonido.ejecutar(creadorDeSonidos.start())
			nivelHabitacion.config() //ACA CONFIGURO EL NIVEL EN EL QUE COMIENZO!!
		}
	}

}

object pantallaInstruccionCroquetas inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instrucciongato.png")
		fotogramas.add("instrucciongato.png")
	}

	method musicaDeNivel() = "musica_gato.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
		keyboard.enter().onPressDo{
			minijuegoCroquetas.config()
		}
	}

}

object pantallaInstruccionMercado inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instruccionesmeli.png")
		fotogramas.add("instruccionesmeli.png")
	}

	method musicaDeNivel() = "musica_fondo_habitacion.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
		keyboard.enter().onPressDo{
			nivelCaptcha1.config()
		}
	}
}

object pantallaCaptchaSuperado inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("pantallacaptchasuperado.png")
		fotogramas.add("pantallacaptchasuperado.png")
	}

	override method config(){
		super()

		keyboard.enter().onPressDo{
			nivelComputadoraV2.config()
		}
	}
}


object pantallaInstruccionVS inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instruccionvs.png")
		fotogramas.add("instruccionvs.png")
	}

	method musicaDeNivel() = "musica_vs.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))

		keyboard.enter().onPressDo{
			nivelVisualStudio.config()
		}
	}

}

object pantallaInstruccionTerraria inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instruccionterraria.png")
		fotogramas.add("instruccionterraria.png")
	}

	method musicaDeNivel() = "musica_terraria.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))

		keyboard.enter().onPressDo{
			nivelTerraria.config()
		}
	}

}

object pantallaInstruccionMerienda inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instruccionespanqueques.png")
		fotogramas.add("instruccionespanqueques.png")
	}

	method musicaDeNivel() = "musica_merienda.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))

		keyboard.enter().onPressDo{
			minijuegoPanqueques.config()
		}
	}

}


object pantallaFin inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("pantallavictoria.png")
		fotogramas.add("pantallavictoria2.png")
	}

	method musicaDeNivel() = "musica_fondo.mp3"

	override method config(){
		super()
		sonido.reproducirMusica(new Ambiente(rutaArchivo = self.musicaDeNivel()))
		sonido.ejecutar(creadorDeSonidos.victoria())
		
		keyboard.enter().onPressDo{
			pantallaInicio.config()
		}
	}

}