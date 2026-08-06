import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Configuração do Supabase do projeto.
///
/// Em produção, prefira usar `--dart-define` para não expor a anon key
/// no código-fonte. Por enquanto usamos constantes por simplicidade.
class SupabaseConfig {
  static const String url = 'https://xbwipfywaksdcxwevfei.supabase.co';
  static const String anonKey =
      'sb_publishable_y1g9psBCmto_AzcT4n04Ng_dJEDue9C';
}

/// Inicializa o cliente do Supabase (deve ser chamado uma única vez,
/// antes de `runApp`).
class SupabaseClientFactory {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    supabase.Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    _initialized = true;
  }

  static supabase.SupabaseClient get instance =>
      supabase.Supabase.instance.client;
}
