import React, { useEffect, useState, useRef } from 'react'
import {
  StatusBar,
  StyleSheet,
  ActivityIndicator,
  Alert,
  BackHandler
} from 'react-native'
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context'
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
  const webViewRef = useRef(null)
  const [canGoBack, setCanGoBack] = useState(false)

  useEffect(() => {
    androidPermissions()
    requestUserPermission()
    setBackgroundMessageHandler()
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

    // Intercepta o botão voltar do Android
  useEffect(() => {
    const backHandler = BackHandler.addEventListener('hardwareBackPress', () => {
      if (canGoBack && webViewRef.current) {
        webViewRef.current.goBack()
        return true // impede de fechar o app
      }
      return false // fecha o app se não tiver histórico
    })
    return () => backHandler.remove()
  }, [canGoBack])

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
  }, 100);`

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
        <StatusBar backgroundColor="#3d4866" barStyle="light-content" />
        <WebView
          ref={webViewRef}
          source={{ uri: BASE_URL }}
          style={styles.webView}
          onLoadEnd={() => setIsLoading(false)}
          onNavigationStateChange={(navState) => setCanGoBack(navState.canGoBack)}
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
    </SafeAreaProvider>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#3d4866',
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