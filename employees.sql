--employees table for the indexing lecture
--paste these commands into the postgres 
--start the docker instance
docker run --name pg -e POSTGRES_PASSWORD=postgres -d postgres

docker start pg
--run postgres command shell
docker exec -it pg psql -U postgres
--the command should switch to 
--postgres=#
-- paste these sql
create table employees( id serial primary key, name text);

create or replace function random_string(length integer) returns text as 
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
  length2 integer := (select trunc(random() * length + 1));
begin
  if length2 < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length2 loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;


insert into employees(name)(select random_string(10) from generate_series(0, 1000000));


\d employees;

select id from employees where id = 1000;
select * from employees where id = 1000;

explain analyze select id from employees where id = 20;
/** Inline query **/


explain analyze select id from employees where id - 3000;
explain analyze select name from employees where id = 5000;
/** index scan **/


explain analyze select id from employees where name = 'Zs';
/** 느림 , name은 index가 없어서 순차 scan을 해야함 sequential scan **/

explain analyze select id,name from employees where name like '%Zs%';
/** name 열 값이 '%Zs%' 패턴을 포함하는 레코드 조회 **/

create index employees_name on employees(name);
/** building b-tree bitmap index **/

explain analyze select id, name from employees where name = 'Zs';

explain analyze select id,name from employees where name like '%Zs%';
/** slow query -> index를 scan할 수 없음 (실수많음) 전체를 돌면서 패턴을 찾아야 함. indexing을 했더라도
db가 꼭 사용하는 건 아님. 플랜을 짜고 플랜에 따라 인덱스를 쓸 지 말지를 결정함 **/






