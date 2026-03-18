.PHONY: start android ios clean clean-all build build-apk build-apk-local build-preview publish submit publish-submit codegen update prebuild credentials help

# ─── Dev ───────────────────────────────────────────────────────────────────────

start: ## Inicia o Metro bundler (servidor de desenvolvimento), ele altera altomaticamente quando a mudança é de JS
	npx expo start

android: ## Compila e roda o app no Android em modo debug
	npx expo run:android

ios: ## Compila e roda o app no iOS em modo debug
	npx expo run:ios

# ─── Codegen ───────────────────────────────────────────────────────────────────
# Necessário sempre que o build Android for limpo (make clean). OU Ser necessário se houver mudanças na interface do react-native-webview (ex: atualização de versão). O codegen é o processo que converte os arquivos de schema do react-native-webview em código C++ que é usado na parte nativa do Android. Sem isso, a parte nativa do Android não consegue se comunicar corretamente com o código JavaScript do React Native, o que pode causar erros ou falhas no app. Portanto, é importante rodar esse comando para garantir que os arquivos C++ estejam atualizados e compatíveis com a versão do react-native-webview que está sendo usada no projeto.
# Gera os arquivos C++ do react-native-webview antes da compilação nativa.

codegen: ## Gera os artefatos de codegen do react-native-webview
	cd android && ./gradlew :react-native-webview:generateCodegenArtifactsFromSchema && cd ..

# ─── Clean ─────────────────────────────────────────────────────────────────────

clean: ## Limpa os arquivos de build do Android (gradle clean)
	cd android && ./gradlew clean && cd ..

clean-all: clean ## Limpa build + apaga node_modules e reinstala dependências
	rm -rf node_modules
	npm install

# ─── Build ─────────────────────────────────────────────────────────────────────

build-apk: ## Gera um APK via EAS (útil para testes em dispositivos)
	eas build --platform android --profile android-apk

build-apk-local: ## Gera um APK localmente sem usar os servidores do EAS
	eas build --platform android --profile android-apk --local

build: ## Gera o AAB de produção via EAS (formato exigido pela Play Store)
	eas build --platform android --profile production

build-preview: ## Gera um build de preview para testes internos via EAS
	eas build --platform android --profile preview

# ─── Publish / Submit ──────────────────────────────────────────────────────────

publish: build ## Alias para build de produção
	@echo "✅ Build de produção enviado para o EAS."

submit: ## Submete o último build para a Play Store via EAS Submit
	eas submit --platform android --profile production

publish-submit: build submit ## Faz o build de produção e já submete para a Play Store
	@echo "✅ Build enviado e submetido para a Play Store."

# ─── Utilitários ───────────────────────────────────────────────────────────────

update: ## Atualiza as dependências para versões compatíveis com o Expo SDK atual
	npx expo install --fix

prebuild: ## Regenera a pasta android/ via Expo prebuild (use com cuidado)
	npx expo prebuild --platform android

credentials: ## Abre o gerenciador de credenciais do EAS (keystore, etc.)
	eas credentials

# ─── Help ──────────────────────────────────────────────────────────────────────

help: ## Lista todos os comandos disponíveis
	@echo ""
	@echo "  HoraBela - Comandos disponíveis"
	@echo "  ──────────────────────────────────────────────────────────"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-20s → %s\n", $$1, $$2}'
	@echo ""