FROM eclipse-temurin:17-jre

WORKDIR /app

# Instalar git y bash
RUN apt-get update && apt-get install -y git bash

# Copiar tu juego
COPY . .

# Clonar wollok-cli
RUN git clone https://github.com/uqbar-project/wollok-cli

# Agregar wollok-cli al PATH
ENV PATH="/app/wollok-cli:${PATH}"

# Render exige un proceso "web", dejamos el juego corriendo
CMD wollok run
