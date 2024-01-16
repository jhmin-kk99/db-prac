--explain explained

-- make sure to run the container with at least 1gb shared memory
-- docker run --name pg —shm-size=1g -e POSTGRES_PASSWORD=postgres —name pg postgres

create table grades (
id serial primary key, 
 g int,
 name text 
); 


insert into grades (g,
name  ) 
select 
random()*100,
substring(md5(random()::text ),0,floor(random()*31)::int)
 from generate_series(0, 500);

vacuum (analyze, verbose, full);

create index g_idx on grades(g);

explain analyze select id,g from grades where g > 80 and g < 95 order by g;

explain select * from grades; 

/** 
QUERY PLAN ... Seq Scan on grades cost a..b 
(a : first page를 가져오는 데 걸린 시간, 이 값이 커지면,you're doing a lot of stuff before fetching.
b : essentially the total amount of time that it thinks (not really excution time)))

rows : not an accurate number, but it gives you a quick number, approximate based on its
own statistics.

Don't do select count. SELECT COUNT will kill your performance. it's actually and physically
do the count on all your rows eventhough you have billion rows.

width: width of the row, this is sum of all the bytes for all the columns.
**/

explain select * from grades order by g; 
/** cost의 첫 숫자가 좀 늘었음 -> postgres did some work or it is attempting to do some work before 
fetching the row. and that work is actually doing the sort order by g, and it's not so bad
because it did use the index that is on g to do the sorting. **/

explain select * from grades order by name;
/** 오래 걸림 name이 indexing 안 되어있음, 다 찾고 sort해야 함 **/

explain select id from grades;
/** width : 4 bytes **/
explain select name from grades;
/** width = 19 ;  바이트 단위로 표시, the larger the network you're going to take,
the higher the TCP packets. don't put like a blob and do select star 
필요한만큼만 select 하셈 **/

explain select * from grades where id = 10;
