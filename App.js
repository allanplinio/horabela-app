import React, { useEffect, useState } from 'react'
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  ActivityIndicator,
  Alert,
  TextInput,
} from 'react-native'
import { WebView } from 'react-native-webview'
import {
  androidPermissions,
  onMessageHandler,
  requestUserPermission,
  setBackgroundMessageHandler,
  takeToken,
} from './config/firebaseConfig'
import { BASE_URL } from './config/config'
import sendTokenExpo, { tokenHorabela } from './api/tokenHorabela'

export default function App() {
  const [isLoading, setIsLoading] = useState(true)
  const [tokenExpo, setTokenExpo] = useState('')
  const [tokenNavigator, setTokenNavigator] = useState('')

  // Configurações do Firebase
  useEffect(() => {
    androidPermissions()
    requestUserPermission()
    setBackgroundMessageHandler()

    // função para receber mensagens em primeiro plano
    const unsubscribe = onMessageHandler(async (remoteMessage) => {
      Alert.alert(remoteMessage.notification.title, remoteMessage.notification.body)
    })
    return unsubscribe
  }, [])

  useEffect(() => {
    takeToken(setTokenExpo)
  }, [])

  useEffect(() => {
    if (tokenNavigator !== '') {
      sendTokenNavigator()
    }
  }, [tokenNavigator])

  function sendTokenNavigator() {
    if (tokenNavigator !== '' && tokenExpo !== '') {
      sendTokenExpo(tokenNavigator, tokenExpo)
    }
  }

  // função em JS para pegar o token no localstorage do navegador
  // e enviar para o React Native. O timeout é necessário para
  // garantir que o token já esteja disponível no localstorage
  const injectedJavaScript = `setTimeout(function () {
        const token = window.localStorage.getItem('token');
        window.ReactNativeWebView.postMessage(token)
      }, 100);
  `
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="auto" />
      <WebView
        source={{ uri: BASE_URL }}
        style={styles.webView}
        onLoadEnd={() => setIsLoading(false)}
        injectedJavaScript={injectedJavaScript}
        onMessage={(event) => {
          if (event.nativeEvent.data !== null) {
            setTokenNavigator(event.nativeEvent.data)
          } else {
            setTokenNavigator('')
          }
        }}
      />
      {isLoading && (
        <ActivityIndicator
          color={'black'}
          size={'large'}
          style={styles.activityIndicator}
        />
      )}
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
  },
  webView: {
    flex: 1,
  },
  activityIndicator: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },
})
