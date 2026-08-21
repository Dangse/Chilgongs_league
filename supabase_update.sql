-- ============================================================
-- 칠공스 리그 · 2026-08-21 업데이트용 스크립트
-- 수파베이스 대시보드 → SQL Editor 에 전체를 붙여넣고 Run 하세요.
-- 여러 번 실행해도 안전합니다(멱등).
-- ============================================================

-- 1) 라운드 1 시작일을 첫 정모일(2026-08-14)로 교정
--    (시작일이 8/14보다 늦게 저장돼 있으면 정모 횟수가 0회로 표시되던 문제)
update public.rounds
   set start_date = '2026-08-14'
 where no = 1 and start_date > '2026-08-14';

insert into public.rounds (no, start_date)
select 1, '2026-08-14'
 where not exists (select 1 from public.rounds where no = 1);

-- 2) 이미 입력된 라운드 1의 결과(1회차 정모 결과)를 8/14 날짜로 이동
--    ※ 라운드 1의 정모가 아직 1회만 진행된 지금 시점(2026-09-11 이전)에 실행하세요.
update public.scores
   set meet_date = '2026-08-14'
 where round = 1 and meet_date <> '2026-08-14';

-- 3) 선수 삭제 기능용 권한 정책 (RLS가 켜져 있는 경우 필요)
drop policy if exists "players_delete_anon" on public.players;
create policy "players_delete_anon" on public.players
  for delete using (true);

drop policy if exists "scores_delete_anon" on public.scores;
create policy "scores_delete_anon" on public.scores
  for delete using (true);

-- 4) 점수 날짜 이동(위 2번을 웹앱이 자동 실행할 때)용 업데이트 정책
drop policy if exists "scores_update_anon" on public.scores;
create policy "scores_update_anon" on public.scores
  for update using (true) with check (true);

drop policy if exists "rounds_update_anon" on public.rounds;
create policy "rounds_update_anon" on public.rounds
  for update using (true) with check (true);
