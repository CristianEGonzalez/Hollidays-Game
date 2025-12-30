import wollok.game.*
import niveles.*
import objetos.*
import nivelCroquetas.*
import nivelMercadoLibre.*
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

	override method config(){
		super()
		keyboard.enter().onPressDo{
			pantallaControles.config()
		}
	}
/*
	override method configuracionAdicional(){
		//const ambiente = new Ambiente()
		nivel.nivelActual().config()
		//sonido.ejecutar(ambiente)
	}
*/
}

object pantallaControles inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("pantallainstruccion.png")
		fotogramas.add("pantallainstruccion.png")
	}

	override method config(){
		super()

		keyboard.enter().onPressDo{ 
			nivelHabitacion.config()
		}
	}

}

object pantallaInstruccionCroquetas inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("instrucciongato.png")
		fotogramas.add("instrucciongato.png")
	}

	override method config(){
		super()

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

	override method config(){
		super()

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