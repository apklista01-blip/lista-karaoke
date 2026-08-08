# TODO - Painel de Estatísticas de Uso (v1.0.5)

## Backend (Supabase) - ✅ Concluído (confirmado pela IA do Supabase)
- [x] Executar `estatisticas_setup.sql` no SQL Editor do Supabase
  - Tabela `acessos` criada (id, dispositivo_id, criado_em)
  - RLS configurado: INSERT público, SELECT apenas autenticado
  - Função RPC `stats_acessos()` criada (SECURITY DEFINER)
  - IA confirmou: tabela, policies e função estão presentes

## Código Flutter - Concluído
- [x] `lib/core/access_log.dart` - gera/recupera device_id e registra acesso
- [x] `lib/models/acesso_stats.dart` - modelo de dados das estatísticas
- [x] `lib/core/access_stats_service.dart` - consulta as estatísticas via RPC
- [x] `lib/pages/home_page.dart` - chama `AccessLog.registrarAcesso()` no initState
- [x] `lib/pages/admin_home_page.dart` - aba "Estatísticas" no painel admin
- [x] `pubspec.yaml` - bump de versão para 1.0.5+6

## Testes - Concluído
- [x] `dart format` nos arquivos alterados
- [x] `flutter analyze` → "No issues found!"

## Publicação
- [ ] Gerar novo build Web (`flutter build web`)
- [ ] Gerar novo APK (`flutter build apk`)
- [ ] Subir para GitHub Pages / publicar APK
