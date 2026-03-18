requeriments:

JAVA = 17
NODE = 20.12.1

instalar dependencias npm = npm install
instalar dependencias expo = npx expo install
- Para realizar o build
  npx expo prebuild
rodar aplicacao para android = npx expo run:android

se necessário instalar o EAS-CLI para buildar

esse é o comando pra buildar local
eas build -p android --profile android-apk --local


nvm install 20.12.1
nvm use 20.12.1

npx expo install @react-native-firebase/messaging

expo upgrade, caso precise apagar a pasta do expo
--sudo npm install expo-cli -g --unsafe-perm


Conecte o celular via USB e:
1. Ative a depuração USB no celular

Configurações → Sobre o telefone → toque 7x em "Número da versão"
Configurações → Opções do desenvolvedor → Ative "Depuração USB"

2. Conecte e verifique
bashadb devices
```

List of devices attached
R58M123ABC    device

Se aparecer unauthorized, aceite a permissão no celular.

3. Rode
bashmake android