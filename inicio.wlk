import wollok.game.*
import niveles.*
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
		fotogramas.add("pantallaInicio1.png")
		fotogramas.add("pantallaInicio2.png")
	}

	override method config(){
		super()
		keyboard.enter().onPressDo{ 
			nivelHabitacion.config()
		}
		keyboard.e().onPressDo{ pantallaCreditos.config() }
	}
/*
	override method configuracionAdicional(){
		//const ambiente = new Ambiente()
		nivel.nivelActual().config()
		//sonido.ejecutar(ambiente)
	}
*/
}

object pantallaCreditos inherits Pantalla {
	override method agregarFotograma(){
		fotogramas.add("cristalina.png")
		fotogramas.add("cristalina.png")
	}

	override method config(){
		super()

		keyboard.enter().onPressDo{ 
			pantallaInicio.config()
		}
	}

}
