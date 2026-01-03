object sonido {
    var musicaActual = null

    // Para efectos cortos
    method ejecutar(unSonido) {
        unSonido.config()
        unSonido.sonido().play()
    }

    // Para música de fondo (Ambiente)
    method reproducirMusica(nuevaMusica) {
        if (musicaActual != null) {
            musicaActual.stop()
        }
        musicaActual = nuevaMusica.sonido()
        nuevaMusica.config()
        musicaActual.play()
    }
}

class Ambiente {
    const property sonido = game.sound("musica_intro.mp3")
    method config() {
        sonido.volume(0.2)
        sonido.shouldLoop(true)
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
    method gatoMiau() = new SonidoCorto(sonido = game.sound("miau.mp3"))
}