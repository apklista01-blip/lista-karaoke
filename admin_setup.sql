-- ============================================================
-- ADMIN SETUP - Karaokê Cabana Dona Angela
-- Execute este script no SQL Editor do Supabase (Dashboard →
-- SQL Editor → New query → Run).
--
-- OBJETIVO:
-- 1) Criar a tabela "mensagens" (para o admin enviar recados
--    que aparecem na HomePage do app).
-- 2) Configurar as RLS policies da tabela "songs" para que
--    apenas usuários autenticados (admin) possam INSERIR,
--    ATUALIZAR e EXCLUIR músicas.
-- 3) Configurar as RLS policies da tabela "mensagens":
--    - LEITURA (SELECT) para TODOS (usuários anônimos leem o recado)
--    - ESCRITA (INSERT/UPDATE/DELETE) apenas para autenticados
-- ============================================================

-- ------------------------------------------------------------
-- 1) TABELA: mensagens
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.mensagens (
  id          BIGSERIAL PRIMARY KEY,
  conteudo    TEXT NOT NULL,
  ativa       BOOLEAN NOT NULL DEFAULT TRUE,
  admin_uid   UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  criada_em   TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.mensagens IS
  'Mensagens enviadas pelo admin, exibidas como banner na HomePage.';

-- ------------------------------------------------------------
-- 2) RLS na tabela SONGCOUNT (songs)
--    Permite leitura para todos (já deve existir) e escrita
--    apenas para usuários autenticados (admin).
-- ------------------------------------------------------------
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;

-- Leitura pública (qualquer pessoa consulta o catálogo)
DROP POLICY IF EXISTS "songs_select_public" ON public.songs;
CREATE POLICY "songs_select_public"
  ON public.songs
  FOR SELECT
  USING (true);

-- Inserir: apenas autenticado
DROP POLICY IF EXISTS "songs_insert_auth" ON public.songs;
CREATE POLICY "songs_insert_auth"
  ON public.songs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Atualizar: apenas autenticado
DROP POLICY IF EXISTS "songs_update_auth" ON public.songs;
CREATE POLICY "songs_update_auth"
  ON public.songs
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Excluir: apenas autenticado
DROP POLICY IF EXISTS "songs_delete_auth" ON public.songs;
CREATE POLICY "songs_delete_auth"
  ON public.songs
  FOR DELETE
  TO authenticated
  USING (true);

-- ------------------------------------------------------------
-- 3) RLS na tabela MENSAAGENS
--    Leitura para todos, escrita apenas autenticado.
-- ------------------------------------------------------------
ALTER TABLE public.mensagens ENABLE ROW LEVEL SECURITY;

-- Leitura pública (usuários leem o recado)
DROP POLICY IF EXISTS "mensagens_select_public" ON public.mensagens;
CREATE POLICY "mensagens_select_public"
  ON public.mensagens
  FOR SELECT
  USING (ativa = true);

-- Inserir: apenas autenticado
DROP POLICY IF EXISTS "mensagens_insert_auth" ON public.mensagens;
CREATE POLICY "mensagens_insert_auth"
  ON public.mensagens
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Atualizar: apenas autenticado
DROP POLICY IF EXISTS "mensagens_update_auth" ON public.mensagens;
CREATE POLICY "mensagens_update_auth"
  ON public.mensagens
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Excluir: apenas autenticado
DROP POLICY IF EXISTS "mensagens_delete_auth" ON public.mensagens;
CREATE POLICY "mensagens_delete_auth"
  ON public.mensagens
  FOR DELETE
  TO authenticated
  USING (true);

-- ------------------------------------------------------------
-- 4) GRANTs (permissões de acesso via API/anonymous key)
-- ------------------------------------------------------------
-- Permite leitura das mensagens por usuários anônimos (anon key)
GRANT SELECT ON public.mensagens TO anon;

-- Permite operações de escrita por usuários autenticados
GRANT INSERT, UPDATE, DELETE ON public.mensagens TO authenticated;

-- Permite leitura/escrita em songs para os papéis adequados
GRANT SELECT ON public.songs TO anon;
GRANT INSERT, UPDATE, DELETE ON public.songs TO authenticated;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
