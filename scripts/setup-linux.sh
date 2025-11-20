#!/usr/bin/env bash
set -euo pipefail

# PAra rodar
# cd /home/allan/Documentos/projects/horabela/horabela-app
# chmod +x scripts/setup-linux.sh
# ./scripts/setup-linux.sh
# # Depois reinicie o terminal ou rode:
# source ~/.bashrc


# Setup script for horabela project on Debian/Ubuntu Linux
# Installs: nvm + Node 18, yarn (optional), OpenJDK 17, Android cmdline-tools, SDK 34, build-tools 34.0.0, NDK 25.1.8937393, creates AVD
# Run: chmod +x scripts/setup-linux.sh && ./scripts/setup-linux.sh

HOME_DIR="$HOME"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME_DIR/Android/Sdk}"
CMDLINE_TOOLS_ZIP_URL="https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
CMDLINE_TOOLS_DIR="$ANDROID_SDK_ROOT/cmdline-tools/latest"
NDK_VERSION="25.1.8937393"
PLATFORM_VERSION="android-34"
BUILD_TOOLS_VERSION="34.0.0"
SYSTEM_IMAGE="system-images;android-34;google_apis;x86_64"
AVD_NAME="Pixel_4_API_34"
NODE_VERSION="18"

info(){ echo -e "\033[1;34m[INFO]\033[0m $*"; }
error(){ echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

if [ "$(id -u)" = "0" ]; then
  error "Não execute este script como root. Execute como usuário normal com sudo quando necessário.";
fi

info "Atualizando repositório apt e instalando dependências básicas..."
if command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y curl wget unzip git ca-certificates zip unzip
else
  info "Não detectei apt; pule instalação de pacotes do sistema. Garanta manualmente curl/wget/unzip/git/zip estão instalados."
fi

# Install nvm and Node
if [ -d "$HOME_DIR/.nvm" ]; then
  info "nvm já instalado."
else
  info "Instalando nvm..."
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME_DIR/.nvm"
  # shellcheck source=/dev/null
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
fi

# load nvm if present
if [ -s "$HOME_DIR/.nvm/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$HOME_DIR/.nvm/nvm.sh"
fi

info "Instalando Node $NODE_VERSION (LTS) via nvm..."
nvm install $NODE_VERSION
nvm alias default $NODE_VERSION

info "Instalando yarn (opcional)..."
if ! command -v yarn >/dev/null 2>&1; then
  npm install -g yarn || info "Falha ao instalar yarn globalmente; pode prosseguir sem yarn."
else
  info "yarn já instalado"
fi

# Install JDK 17
if java -version 2>&1 | grep -q 'openjdk version \|"17'; then
  info "JDK 17 já instalado"
else
  if command -v apt >/dev/null 2>&1; then
    info "Instalando OpenJDK 17 via apt..."
    sudo apt install -y openjdk-17-jdk
  else
    info "Não detectei apt. Instale JDK 17 manualmente e defina JAVA_HOME."
  fi
fi

# Set JAVA_HOME if not set
if [ -z "${JAVA_HOME:-}" ]; then
  JAVA_PATH_CANDIDATE="/usr/lib/jvm/java-17-openjdk-amd64"
  if [ -d "$JAVA_PATH_CANDIDATE" ]; then
    echo "export JAVA_HOME=$JAVA_PATH_CANDIDATE" >> "$HOME_DIR/.bashrc"
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> "$HOME_DIR/.bashrc"
    export JAVA_HOME="$JAVA_PATH_CANDIDATE"
    export PATH="$JAVA_HOME/bin:$PATH"
    info "JAVA_HOME definido para $JAVA_HOME (adicionado em ~/.bashrc)."
  else
    info "Não encontrei automaticamente JDK 17. Verifique manualmente e defina JAVA_HOME no seu ~/.bashrc"
  fi
else
  info "JAVA_HOME já definido: $JAVA_HOME"
fi

# Android SDK installation
info "Configurando Android SDK em $ANDROID_SDK_ROOT"
mkdir -p "$ANDROID_SDK_ROOT"
mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"

# Download and install commandline tools if missing
if [ ! -d "$CMDLINE_TOOLS_DIR" ]; then
  TMP_ZIP="/tmp/cmdline-tools.zip"
  info "Baixando Android commandline tools..."
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_ZIP" "$CMDLINE_TOOLS_ZIP_URL" || error "Falha ao baixar commandline tools. Verifique a URL no script."
  else
    curl -fsSL -o "$TMP_ZIP" "$CMDLINE_TOOLS_ZIP_URL" || error "Falha ao baixar commandline tools. Instale wget ou curl."
  fi
  info "Descompactando..."
  unzip -q "$TMP_ZIP" -d "/tmp/cmdline-tools-unpack"
  mkdir -p "$CMDLINE_TOOLS_DIR"
  # mover conteúdo para cmdline-tools/latest
  mv /tmp/cmdline-tools-unpack/cmdline-tools/* "$CMDLINE_TOOLS_DIR/"
  rm -rf /tmp/cmdline-tools-unpack "$TMP_ZIP"
  info "Commandline tools instalados em $CMDLINE_TOOLS_DIR"
else
  info "Android commandline tools já presentes em $CMDLINE_TOOLS_DIR"
fi

# Add Android SDK env vars to ~/.bashrc if not present
if ! grep -q "ANDROID_SDK_ROOT" "$HOME_DIR/.bashrc" 2>/dev/null; then
  echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> "$HOME_DIR/.bashrc"
  echo "export ANDROID_HOME=\$ANDROID_SDK_ROOT" >> "$HOME_DIR/.bashrc"
  echo "export PATH=\$PATH:\$ANDROID_SDK_ROOT/emulator:\$ANDROID_SDK_ROOT/platform-tools:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin" >> "$HOME_DIR/.bashrc"
  info "Variáveis do Android SDK adicionadas em ~/.bashrc (execute 'source ~/.bashrc')."
fi

# Ensure sdkmanager exists
SDKMANAGER="$CMDLINE_TOOLS_DIR/bin/sdkmanager"
if [ ! -x "$SDKMANAGER" ]; then
  error "Não encontrei sdkmanager em $SDKMANAGER"
fi

info "Instalando pacotes Android: platform-tools, platforms;android-34, build-tools;34.0.0, emulator, ndk;$NDK_VERSION, system image"
# Use --sdk_root para garantir instalação no local desejado
yes | "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" "platform-tools" "platforms;android-34" "build-tools;${BUILD_TOOLS_VERSION}" "emulator" "ndk;${NDK_VERSION}" "$SYSTEM_IMAGE" || info "Alguns pacotes podem ter falhado; verifique a saída acima."

# Accept licenses
info "Aceitando licenças do Android SDK..."
yes | "$SDKMANAGER" --sdk_root="$ANDROID_SDK_ROOT" --licenses || info "Aceitação automática de licenças pode ter falhado; execute manualmente: $SDKMANAGER --sdk_root=$ANDROID_SDK_ROOT --licenses"

# Create AVD if avdmanager available
AVDMANAGER="$CMDLINE_TOOLS_DIR/bin/avdmanager"
if [ -x "$AVDMANAGER" ]; then
  # Check if AVD exists
  if "$AVDMANAGER" list avd | grep -q "$AVD_NAME"; then
    info "AVD $AVD_NAME já existe."
  else
    info "Criando AVD $AVD_NAME com imagem $SYSTEM_IMAGE (pode demorar)..."
    echo "no" | "$AVDMANAGER" create avd -n "$AVD_NAME" -k "$SYSTEM_IMAGE" --device "pixel" || info "Falha ao criar AVD; verifique se a imagem do sistema foi instalada."
    info "AVD criado: $AVD_NAME"
  fi
else
  info "avdmanager não encontrado; pule criação de AVD."
fi

info "Instalação/Configuração concluída. Reinicie o terminal ou rode: source ~/.bashrc"
info "Para executar o projeto: cd <repo-root> && npm install && npm run android"

exit 0
