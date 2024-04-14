import messaging from '@react-native-firebase/messaging'
import { PermissionsAndroid, Platform } from 'react-native'

// função para pedir permissão de notificação
export async function requestUserPermission() {
  const authStatus = await messaging().requestPermission()
  const enabled =
    authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
    authStatus === messaging.AuthorizationStatus.PROVISIONAL

  if (enabled) {
    console.log('Authorization status:', authStatus)
  }
}

// função para receber mensagens em segundo plano
export function setBackgroundMessageHandler() {
  messaging().setBackgroundMessageHandler(async (remoteMessage) => {
    console.log('Message handled in the background!', remoteMessage)
  })
}

// função para receber mensagens em primeiro plano
export function onMessageHandler(callback) {
  return messaging().onMessage(callback)
}

// função para pegar o token do dispositivo
export async function takeToken(setTokenExpo) {
  await messaging().registerDeviceForRemoteMessages()
  const tokenAux = await messaging().getToken()
  setTokenExpo(tokenAux)
}

// função para pedir permissão de notificação no Android
export async function androidPermissions() {
  if (Platform.OS === 'android') {
    const granted = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.POST_NOTIFICATIONS
    )
    // verificação se a permissão foi concedida
    if (granted === PermissionsAndroid.RESULTS.GRANTED) {
      console.log('You can use the POST_NOTIFICATIONS')
    } else {
      console.log('POST_NOTIFICATIONS permission denied')
    }
  }
}
