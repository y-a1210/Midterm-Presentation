-- =====================================================================
-- SORAMADO UI比較アンケート：回答の受け取り側（Supabase）v3.1
-- Supabase の「SQL Editor」にこのファイルの中身を全部貼り付けて「Run」を押す（1回だけ）。
--
-- ・回答は survey_sessions 表に、参加者ごとに1行（記録全体を data 列に）入ります。
-- ・表は「行レベルのセキュリティ（RLS）」を有効にし、決まりを1つも作らないので、
--   公開鍵（Publishable / anon key）では表を直接読むことも書くこともできません。
--   参加者のブラウザが使えるのは、下の3つの関数だけです：
--     survey_submit      … 回答を1人分保存する（完了した記録を途中の記録で上書きしない）
--     survey_next_alloc  … 画面の順序の割付の番号を1つ渡す（1, 2, 3, …）
--     survey_list        … 読み取りキーが合っているときだけ、全員の記録を返す（研究者メニュー用）
-- ・読み取りキーは自動で作られ、survey_settings 表の read_key の行にあります（Table Editor で見られる）。公開しないこと。
-- ・本番の前に試しの回答を消すとき：一番下の「本番の前に」の2行を実行する。
-- =====================================================================

create table if not exists public.survey_sessions (
  pid         text primary key check (pid ~ '^[A-Za-z0-9_.@-]{1,64}$'),
  status      text not null default 'in_progress',
  order_seq   text,
  app_version text,
  device      text,
  reason      text,
  data        jsonb not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create table if not exists public.survey_settings (
  name  text primary key,
  value text not null
);
create sequence if not exists public.survey_alloc start 1;

alter table public.survey_sessions enable row level security;
alter table public.survey_settings enable row level security;
revoke all on table public.survey_sessions from anon, authenticated;
revoke all on table public.survey_settings from anon, authenticated;
revoke all on sequence public.survey_alloc from anon, authenticated;

insert into public.survey_settings (name, value)
values ('read_key', replace(gen_random_uuid()::text, '-', ''))
on conflict (name) do nothing;

create or replace function public.survey_submit(p_pid text, p_status text, p_reason text, p_data jsonb)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare prev text;
begin
  if p_pid is null or p_pid !~ '^[A-Za-z0-9_.@-]{1,64}$' then
    return json_build_object('ok', false, 'error', 'pid');
  end if;
  if p_status is null or p_status not in ('in_progress', 'complete') then
    return json_build_object('ok', false, 'error', 'status');
  end if;
  if p_data is null or jsonb_typeof(p_data) <> 'object' or octet_length(p_data::text) > 3000000 then
    return json_build_object('ok', false, 'error', 'data');
  end if;
  select status into prev from public.survey_sessions where pid = p_pid;
  if prev = 'complete' and p_status <> 'complete' then
    return json_build_object('ok', true, 'skipped', 'older');
  end if;
  insert into public.survey_sessions (pid, status, order_seq, app_version, device, reason, data, updated_at)
  values (p_pid, p_status, p_data ->> 'order_seq', p_data ->> 'app_version', p_data -> 'log' -> 'meta' ->> 'device', left(coalesce(p_reason, ''), 40), p_data, now())
  on conflict (pid) do update
    set status = excluded.status, order_seq = excluded.order_seq, app_version = excluded.app_version,
        device = excluded.device, reason = excluded.reason, data = excluded.data, updated_at = now();
  return json_build_object('ok', true);
end;
$$;

create or replace function public.survey_next_alloc()
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object('ok', true, 'n', nextval('public.survey_alloc'));
$$;

create or replace function public.survey_list(p_key text)
returns json
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_key is null or p_key <> (select value from public.survey_settings where name = 'read_key') then
    return json_build_object('ok', false, 'error', 'key');
  end if;
  return json_build_object('ok', true, 'sessions',
    coalesce((select json_agg(data order by pid) from public.survey_sessions), '[]'::json));
end;
$$;

revoke all on function public.survey_submit(text, text, text, jsonb) from public;
revoke all on function public.survey_next_alloc() from public;
revoke all on function public.survey_list(text) from public;
grant execute on function public.survey_submit(text, text, text, jsonb) to anon, authenticated;
grant execute on function public.survey_next_alloc() to anon, authenticated;
grant execute on function public.survey_list(text) to anon, authenticated;

-- 読み取りキーを見る（結果の value が読み取りキー）
select value as read_key from public.survey_settings where name = 'read_key';

-- ---------------------------------------------------------------------
-- 本番の前に（試しの回答を消して、割付を1番からにする）。使うときは先頭の -- を消して実行
-- delete from public.survey_sessions;
-- alter sequence public.survey_alloc restart with 1;
-- ---------------------------------------------------------------------
