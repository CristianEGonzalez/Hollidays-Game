object sonido {
    var musicaActual = null
    var rutaActual = ""

    // Para efectos cortos (COMO EL MIAU)
    method ejecutar(unSonido) {
        unSonido.config()
        unSonido.sonido().play()
    }

    // Para música de fondo
    method reproducirMusica(nuevaMusica) {
        if (rutaActual != nuevaMusica.rutaArchivo()) {
            if (musicaActual != null) {
                musicaActual.stop()
            }
            // Guardamos la referencia al objeto de sonido de Wollok
            musicaActual = nuevaMusica.instanciaSonido() 
            rutaActual = nuevaMusica.rutaArchivo()
            nuevaMusica.config()
            musicaActual.play()
        }
    }

    method detenerMusica() {
        if (musicaActual != null) {
            musicaActual.stop()
            musicaActual = null
            rutaActual = ""
        }
    }
}

class Ambiente {
    const property rutaArchivo
    // Cambiamos el nombre aquí para evitar conflictos
    const property instanciaSonido = game.sound(rutaArchivo)
    
    method config() {
        instanciaSonido.volume(0.2)
        instanciaSonido.shouldLoop(true)
    }
}
class SonidoCorto {
    const property sonido
    
    method config() {
        sonido.volume(0.5)
        sonido.shouldLoop(false)
    }
}

object creadorDeSonidos {
    method start() = new SonidoCorto(sonido = game.sound("nintendo-game-boy-startup.mp3"))
    method gatoMiau() = new SonidoCorto(sonido = game.sound("miau.mp3"))
    method bug() = new SonidoCorto(sonido = game.sound("bug.mp3"))
    method caminata() = new SonidoCorto(sonido = game.sound("caminata.mp3"))
    method victoria() = new SonidoCorto(sonido = game.sound("Victory.mp3"))
}