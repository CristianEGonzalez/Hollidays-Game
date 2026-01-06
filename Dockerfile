FROM eclipse-temurin:17-jre

WORKDIR /app

# Instalar curl
RUN apt-get update && apt-get install -y curl

# Descargar Wollok CLI (versión estable)
RUN curl -fL https://github.com/uqbar-project/wollok-cli/releases/download/v2.6.0/wollok-cli-linux \
    -o wollok && chmod +x wollok

# Copiar el proyecto
COPY . .

# Puerto del juego
EXPOSE 4200

# Ejecutar el juego
CMD ["./wollok", "juego.wpgm"]
