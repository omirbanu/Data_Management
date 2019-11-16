## QUERIEES NUMBERS: 4 and 10
use imdb2;

##4 6.688s ~6 or 7s
# show movies where roles were performed by more actresses than actors
/*
973 rows
*/
#BEFORE OPTIMIZATION
SHOW INDEX FROM actors;
ALTER TABLE  actors DROP INDEX  idx_actors_gender;

explain
select mm.*,fc.Fc, mc.Mc #Mc-Male count, Fc-Female count
from (
	select count(r1.actor_id) as Fc, r1.movie_id as mov1
	from roles r1 join actors a1 on r1.actor_id=a1.id 
    where a1.gender='F' 
    group by  r1.movie_id
    ) fc
join (
	select count( r2.actor_id) as Mc, r2.movie_id as mov2 
	from roles r2 join actors a2 on r2.actor_id=a2.id 
    where a2.gender='M' 
    group by  r2.movie_id) 
    mc on fc.mov1=mc.mov2
join movies mm on fc.mov1=mm.id 
where fc.Fc>mc.Mc;

#AFTER OPTIMIZATION
/*
Creating indexes and views for subqueries

#Index all the predicates in JOIN, WHERE, ORDER BY and GROUP BY clauses.

in JOIN and GROUP BY 
ALREADY MADE BY A PRIMARY KEY REFRENECE
*/
/* in WHERE 
*/
create index idx_actors_gender on actors(gender);
 
 /* 
 CREATING 2 VIEWS FROM SUBQERIES
*/
create or replace view fc
as
	select count(rr2.actor_id) as Fc, rr2.movie_id as mov1
	from roles rr2 join actors aa2 on rr2.actor_id=aa2.id 
    where aa2.gender='F' 
    group by  rr2.movie_id;
    
 create or replace view mc
 as
	select count( rr2.actor_id) as Mc, rr2.movie_id as mov2 
	from roles rr2 join actors aa2 on rr2.actor_id=aa2.id 
    where aa2.gender='M' 
    group by  rr2.movie_id;
    
explain 
select mm.id,mm.name,mm.year,mm.rank,fc.Fc, mc.Mc #Mc-Male count, Fc-Female count
from fc
join mc on fc.mov1=mc.mov2
join movies mm on fc.mov1=mm.id 
where fc.Fc>mc.Mc;



 /* 
 WITH CREATED TABLE IS EVEN FASTER
*/ 
create table movies_mf_count (
movie_id int(11) primary key,
mc int(3),
fc int(3)
);
insert into movies_mf_count
	select mov1 as movie_id,Fc as fc,Mc as mc from fc as movie_id join mc on mov1=mov2;

explain 
select mm.id,mm.name,mm.year,mm.rank,fc, mc #Mc-Male count, Fc-Female count
from movies mm join movies_mf_count on id=movie_id
where fc>mc;



#10849
# show when actor has more than 3 roles in the last 60 years
ALTER TABLE  movies DROP INDEX  idx_year;
ALTER TABLE  movies DROP INDEX  idx_rank;

ALTER TABLE  actors DROP INDEX  idx_last_name;
ALTER TABLE  actors DROP INDEX  idx_first_name;

SHOW INDEX FROM movies;
SHOW INDEX FROM actors;
 
#BEFORE OPTIMIZATION ----> running without indexes is super slow :) --> 155-160s??
explain 
select a.*, sc1.cc as count_of_roles 
from actors a
join (
		select sc.actor_id,sc.cc 
        from (
				select r.actor_id, count(r.movie_id) as cc 
                from roles r join movies m on r.movie_id=m.id 
                where m.year>=EXTRACT(YEAR FROM CURRENT_DATE)-60
				group by r.actor_id) sc
		where sc.cc>=3) 
sc1 on sc1.actor_id=a.id;

#10849
#AFTER OPTIMIZATION 
/*
Creating indexes

*/
#Index all the predicates in JOIN, WHERE, ORDER BY and GROUP BY clauses.

# in ORDER BY
create index idx_last_name on actors(last_name);
create index idx_first_name on actors(first_name);
create index idx_rank on movies(`rank`);


/* in GROUP BY 
ALREADY MADE BY A PRIMARY KEY REFRENECE
*/
/* in where 
*/
create index idx_year on movies(`year`); 
 
 
 /*
Creating table
*/

SET SQL_SAFE_UPDATES = 0;
drop table actor_roles_count;
create table actor_roles_count (
actor_id int(11) primary key,
count_of_roles int(3)
);
insert into actor_roles_count
	select r.actor_id, count(r.movie_id) as count_of_roles 
	from roles r join movies m on r.movie_id=m.id 
	where m.year>=EXTRACT(YEAR FROM CURRENT_DATE)-60  
	group by r.actor_id;

SHOW INDEX FROM actor_roles_count;
create index idx_count_of_roles on actor_roles_count(count_of_roles); 


create or replace view sc
as
select actor_id,count_of_roles 
from actor_roles_count 
where count_of_roles>=3;

#TABLE+VIEW
select a.id,a.first_name,a.last_name,a.gender, sc1.count_of_roles 
from actors a
join (
		select actor_id,count_of_roles 
        from sc
	  ) 
sc1 on sc1.actor_id=a.id; 

#TABLE+CONDITION
select a.id,a.first_name,a.last_name,a.gender, sc1.count_of_roles 
from actors a
join (
		select actor_id,count_of_roles 
        from  actor_roles_count 
		where count_of_roles>=3
	  ) 
sc1 on sc1.actor_id=a.id;


#your query
select a.*, sc1.cc as count_of_roles 
from actors a
join (
		select sc.actor_id,sc.cc 
        from (
				select r.actor_id, count(r.movie_id) as cc 
                from roles r join movies m on r.movie_id=m.id 
                where m.year>=EXTRACT(YEAR FROM CURRENT_DATE)-60
				group by r.actor_id) sc
		where sc.cc>=3) 
sc1 on sc1.actor_id=a.id;
 
 
 
 
