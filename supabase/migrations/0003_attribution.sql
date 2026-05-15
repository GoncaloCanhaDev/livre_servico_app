-- Adds attribution columns to every user-facing collection. The app
-- writes the signed-in user's initials (e.g. "GC") on the first save
-- of each row; subsequent updates don't overwrite the value.
--
-- Run this in Supabase → SQL Editor.

alter table shift_events       add column if not exists created_by_initials text;
alter table truck_receptions   add column if not exists created_by_initials text;
alter table products           add column if not exists created_by_initials text;
alter table opening_lists      add column if not exists created_by_initials text;
alter table auto_lists         add column if not exists created_by_initials text;
alter table report_lists       add column if not exists created_by_initials text;
alter table visual_lists       add column if not exists created_by_initials text;
alter table inventories        add column if not exists created_by_initials text;
alter table info_entries       add column if not exists created_by_initials text;

-- Per-checkbox attribution on daily_tasks.
alter table daily_tasks add column if not exists kiwi_abertura_by              text;
alter table daily_tasks add column if not exists alteracoes_preco_by           text;
alter table daily_tasks add column if not exists verificacao_temperaturas_by   text;
alter table daily_tasks add column if not exists preenchimento_quadro_by       text;
alter table daily_tasks add column if not exists verificacao_validades_by      text;
alter table daily_tasks add column if not exists kiwi_fecho_by                 text;
alter table daily_tasks add column if not exists limpeza_maquina_voltas_by     text;
