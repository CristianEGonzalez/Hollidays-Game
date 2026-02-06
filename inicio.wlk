import wollok.game.*
import pantallas.*

object comienzo {
	method config() {
		game.title("Our Love Story: The Next Patch")
		game.height(16)
		game.width(16)
		game.cellSize(50)
		game.addVisual(pantallas.inicio())
		pantallas.inicio().config()
	}
}