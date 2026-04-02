# TDD no My Gang

1. **Regra primeiro**: descreva o comportamento em `test/core/domain/*_test.dart` (nome do teste = regra de negócio).
2. **Vermelho**: rode `flutter test` — o teste falha porque o código em `lib/core/domain/` ainda não existe ou está incompleto.
3. **Verde**: implemente o mínimo em `lib/core/domain/` até o teste passar.
4. **Refatorar**: simplifique mantendo os testes verdes.

Camadas **puras** (`lib/core/domain/`) não importam Firebase nem `flutter`; só Dart. UI e repositórios usam essas funções antes de persistir.

## Primeira execução do projeto

1. Na raiz do repositório: `flutter create .` (gera `android/`, `ios/` e completa `web/` se faltar algo).
2. `dart pub global activate flutterfire_cli` e `flutterfire configure` para substituir [lib/firebase_options.dart](lib/firebase_options.dart).
3. Publicar [firebase/firestore.rules](firebase/firestore.rules) no Console Firebase.
4. Testes: `flutter test` (inclui `test/core/domain/` e smoke em [test/widget_test.dart](test/widget_test.dart)).

## Firebase (login obrigatório na sua máquina)

Não dá para gerar `firebase_options` nem publicar regras sem conta Google. Depois de `brew install firebase-cli` e `dart pub global activate flutterfire_cli`, rode na raiz do repo:

`./tool/firebase_setup.sh`

Ou manualmente: `firebase login`, `flutterfire configure --platforms=web,android,ios --yes --project=SEU_ID`, `firebase deploy --only firestore:rules --project=SEU_ID`. O arquivo [firebase.json](firebase.json) aponta as regras em [firebase/firestore.rules](firebase/firestore.rules).
