# My Gang

App Flutter para criar comunidades, pedir entrada com questionário definido por administradores e organizar eventos presenciais, online ou híbridos. Inspirado na ideia de grupos e encontros no estilo Meetup, focado no contexto brasileiro. Uso gratuito no sentido de não haver cobrança dentro do app; o backend usa o plano gratuito do Firebase dentro das quotas.

## Stack

Flutter (iOS, Android e Web com PWA), Firebase Authentication, Cloud Firestore, go_router e Material 3 com interface simples.

## Funcionalidades principais

Conta com e-mail e senha, perfil mínimo, listagem e criação de grupos, painel de administração para perguntas de entrada e para aprovar ou recusar pedidos, criação de eventos por tipo (presencial, online, híbrido) e confirmação de presença (RSVP) nos eventos.

## Como rodar

Precisa do Flutter no PATH, projeto Firebase configurado e regras do Firestore publicadas. Passos resumidos:

1. `flutter pub get`
2. `flutterfire configure` (ou copiar `google-services.json` e `GoogleService-Info.plist` conforme a documentação do Firebase)
3. `firebase deploy --only firestore:rules` na raiz do repositório
4. `flutter run` ou `flutter run -d chrome` para Web

Há um script auxiliar em `tool/firebase_setup.sh` e notas sobre testes orientados a regras de negócio em `docs/TDD.md`.

## Testes

`flutter test` inclui testes de domínio em `test/core/domain/`.
