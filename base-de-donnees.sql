-- CHAPEPH Book : à coller dans Supabase > SQL Editor > Run
create table profiles(id uuid primary key references auth.users on delete cascade, nom text, role text not null default 'consultation' check(role in('admin','secretaire','consultation')));
create table departements(id serial primary key, nom text unique not null);
create table membres(id uuid primary key default gen_random_uuid(), numero serial, d jsonb not null default '{}', version int not null default 1, cree timestamptz default now(), cree_par text, maj_par text, maj timestamptz default now());
create table photos(membre_id uuid primary key references membres on delete cascade, img text);

create function mon_role() returns text language sql security definer stable set search_path=public as $$ select role from profiles where id=auth.uid() $$;
create function nouveau_profil() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into profiles(id,nom,role) values(new.id,new.email,case when exists(select 1 from profiles) then 'consultation' else 'admin' end); return new; end $$;
create trigger t_profil after insert on auth.users for each row execute function nouveau_profil();

alter table profiles enable row level security; alter table departements enable row level security; alter table membres enable row level security; alter table photos enable row level security;
create policy lire on profiles for select to authenticated using(mon_role() is not null);
create policy maj on profiles for update to authenticated using(mon_role()='admin');
create policy lire on departements for select to authenticated using(mon_role() is not null);
create policy ecrire on departements for all to authenticated using(mon_role()='admin') with check(mon_role()='admin');
create policy lire on membres for select to authenticated using(mon_role() is not null);
create policy ajout on membres for insert to authenticated with check(mon_role() in('admin','secretaire'));
create policy modif on membres for update to authenticated using(mon_role() in('admin','secretaire'));
create policy suppr on membres for delete to authenticated using(mon_role()='admin');
create policy lire on photos for select to authenticated using(mon_role() is not null);
create policy ecrire on photos for all to authenticated using(mon_role() in('admin','secretaire')) with check(mon_role() in('admin','secretaire'));

alter publication supabase_realtime add table membres;
insert into departements(nom) values('Louange'),('Jeunesse'),('Évangélisation'),('Intercession'),('Diaconat'),('École du dimanche'),('Accueil'),('Communication');
