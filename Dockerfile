FROM eclipse-temurin:17-jre

WORKDIR /app

# Instalar curl
RUN apt-get update && apt-get install -y curl

# Descargar Wollok CLI
RUN curl -L https://github.com/uqbar-project/wollok-cli/releases/latest/download/wollok-cli-linux -o wollok \
    && chmod +x wollok

# Copiar el proyecto
COPY . .

# Puerto del Wollok Game
EXPOSE 4200

# Comando de arranque
CMD ["./wollok", "juego.wpgm"]
