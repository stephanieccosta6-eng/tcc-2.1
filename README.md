# GlowUp TCC — Grupo Carefull (Turma DS2B) — Versão v4

## Melhorias Implementadas conforme Feedback da Banca
1. **Login e Cadastro sem dados pré-existentes**: Campos iniciam 100% vazios contendo apenas `hintText` (placeholder).
2. **Segurança e Regex de Senha Forte**: Validação em tempo real no Flutter e no Node.js exigindo mínimo de 8 caracteres, letra maiúscula, minúscula, número e caractere especial, além de e-mail com `@` e hash `bcryptjs`.
3. **Questionário de Pele Opcional (Pós-Login)**: O usuário faz login/cadastro primeiro e responde ao perfil de pele opcionalmente na tela inicial para persistir no banco.
4. **Legibilidade, Contraste e Paleta**: Fontes ampliadas em títulos, descrições, botões (`Create Account`), carrinho e rotina; contraste ajustado entre amarelo/âmbar e rosa; tela de Planos colorida (Rose + Lavanda) evitando excesso de preto e branco.
5. **Tradução Integral PT-BR / EN**: Alternância de idioma em todas as telas, botões e mensagens.
6. **LGPD, Parcerias Comerciais e Comprovante**: Aviso de conformidade com a LGPD no cadastro, seção de transparência/contratos com criadores e emissão de comprovante na assinatura de planos.

## Como executar
1. **Backend (`backend/`)**: Renomeie `.env.example` para `.env`, insira a URI do MongoDB Atlas, rode `npm install` e `npm start`.
2. **Flutter (`flutter_app/`)**: Dentro da pasta `flutter_app`, execute `flutter create .`, `flutter pub get` e `flutter run -d chrome`.
"# tcc-2.1" 
