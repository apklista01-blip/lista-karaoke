-- ============================================================
-- ESTATISTICAS SETUP - Karaokê Cabana Dona Angela
-- Execute este script no SQL Editor do Supabase (Dashboard →
-- SQL Editor → New query → Run) para criar a tabela "acessos"
-- e configurar as permissões.
--
-- OBJETIVO:
-- Registrar cada abertura do app (APK e Web) na tabela "acessos",
-- permitindo ao admin consultar estatísticas de uso:
--   - acessos hoje
--   - acessos na semana (7 dias)
--   - acessos no mês (30 dias)
--   - total de acessos
--   - histórico por dia
--
-- A contagem de "pessoas" é feita por dispositivo_id único
-- (id gerado no próprio aparelho/navegador do usuário).
-- ============================================================

-- ------------------------------------------------------------
-- 1) TABELA: acessos
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.acessos (
  id             BIGSERIAL PRIMARY KEY,
  dispositivo_id TEXT NOT NULL,          -- id único por dispositivo/navegador
  criado_em      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índice para acelerar as consultas por data
CREATE INDEX IF NOT EXISTS idx_acessos_data ON public.acessos (criado_em);
CREATE INDEX IF NOT EXISTS idx_acessos_dispositivo ON public.acessos (dispositivo_id);

COMMENT ON TABLE public.acessos IS
  'Registra aberturas do app para estatísticas de uso.';

-- ------------------------------------------------------------
-- 2) RLS na tabela acessos
--    INSERT: público (qualquer usuário registra o acesso)
--    SELECT: apenas autenticado (admin vê as estatísticas)
--    UPDATE/DELETE: não necessário (mantém histórico)
-- ------------------------------------------------------------
ALTER TABLE public.acessos ENABLE ROW LEVEL SECURITY;

-- Inserir: qualquer pessoa (anon) pode registrar o acesso
DROP POLICY IF EXISTS "acessos_insert_public" ON public.acessos;
CREATE POLICY "acessos_insert_public"
  ON public.acessos
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Ler: apenas usuários autenticados (admin)
DROP POLICY IF EXISTS "acessos_select_auth" ON public.acessos;
CREATE POLICY "acessos_select_auth"
  ON public.acessos
  FOR SELECT
  TO authenticated
  USING (true);

-- ------------------------------------------------------------
-- 3) GRANTs (permissões via API)
-- ------------------------------------------------------------
GRANT INSERT ON public.acessos TO anon;
GRANT INSERT, SELECT ON public.acessos TO authenticated;

-- ------------------------------------------------------------
-- 4) FUNÇÃO RPC: stats_acessos
--    Retorna os contadores de acessos únicos por dispositivo.
--    Executada com SECURITY DEFINER para só o admin ler.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.stats_acessos()
RETURNS json
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT json_build_object(
    'hoje',   (SELECT COUNT(DISTINCT dispositivo_id) FROM public.acessos
               WHERE criado_em >= date_trunc('day', now())),
    'semana', (SELECT COUNT(DISTINCT dispositivo_id) FROM public.acessos
               WHERE criado_em >= now() - interval '7 days'),
    'mes',    (SELECT COUNT(DISTINCT dispositivo_id) FROM public.acessos
               WHERE criado_em >= now() - interval '30 days'),
    'total',  (SELECT COUNT(*) FROM public.acessos),
    'por_dia', (
      SELECT COALESCE(json_agg(row_to_json(d)), '[]'::json)
      FROM (
        SELECT to_char(criado_em AT TIME ZONE 'America/Sao_Paulo', 'YYYY-MM-DD') AS data,
               COUNT(DISTINCT dispositivo_id) AS total
        FROM public.acessos
        WHERE criado_em >= now() - interval '7 days'
        GROUP BY data
        ORDER BY data DESC
      ) d
    )
  );
$$;

-- Somente autenticados (admin) podem chamar a função
REVOKE ALL ON FUNCTION public.stats_acessos() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.stats_acessos() TO authenticated;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
