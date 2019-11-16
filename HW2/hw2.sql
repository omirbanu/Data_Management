use imdb2;

##7
# show actors whose movies had a greater rank than its avg in its genre in that year
select distinct a.*
from actors a join roles r on r.actor_id=a.id join movies m on m.id=r.movie_id join movies_genres g on m.id=g.movie_id
where m.rank > (
				select sc.avg_r 
                from (
					select g.genre, avg(m.rank) as avg_r, m.year
					from movies m join movies_genres g on m.id=g.movie_id 
					group by g.genre, m.year) sc 
				where sc.genre=g.genre and sc.year=m.year)
order by a.first_name,a.last_name;

####################################################
#drop table hw2;

create table hw2 (
genre varchar(40),
avg_r float,
year int(11)
);
insert into hw2
select g.genre, avg(m.rank) as avg_r, m.year
from movies m join movies_genres g on m.id=g.movie_id 
group by g.genre, m.year;


select a.*
from actors a join roles r on r.actor_id=a.id
join movies m on m.id=r.movie_id
join movies_genres g on m.id=g.movie_id
join hw2 sc 
on sc.genre=g.genre and sc.year=m.year
where m.rank > sc.avg_r;
                
##9
#show actors and their movies and roles in the same row who had at least 3 roles
 
select CONCAT(a.first_name,' ',a.last_name) as actor_name,  m_f.list_of_movies, m_r.list_of_roles
from (
		select r.actor_id, group_concat(m.name, ' ') as list_of_movies, count(m.name) as c_m
        from roles r
		join movies m on m.id=r.movie_id  
        group by r.actor_id) m_f
join (
		select r.actor_id, group_concat(r.role, ' ') as list_of_roles , count(r.role) as c_m
        from roles r 
        group by r.actor_id) m_r
on m_f.actor_id=m_r.actor_id 
join actors a on a.id=m_f.actor_id
where m_r.c_m>2
order by a.first_name, a.last_name;


######################
# after optimizing 
#show actors and their movies and roles in the same row who had at least 3 roles

alter table actors
add column C_r int(5);
#create index idx_count_of_roles on actors(C_r); 
#ALTER TABLE  actors DROP INDEX  idx_count_of_roles;
#show index from actors;
update actors
set C_r= (select count(r1.role) from roles r1 where r1.actor_id=id group by r1.actor_id);
#SHOW INDEX FROM actors;
#SHOW INDEX FROM roles;
#create index idx_mov on roles(movie_id); 
#ALTER TABLE  roles DROP INDEX  idx_mov;

select a.first_name,a.last_name, group_concat(m.name, ' ') as list_of_movies,
group_concat(r.role, ' ') as list_of_roles
from actors a
join roles r on a.id=r.actor_id
join movies m on m.id=r.movie_id
where a.C_r>2
group by r.actor_id;
#order by a.first_name;

#___________________________________
# second version
select a.first_name,a.last_name, m.name,r.role
from actors a
join roles r on a.id=r.actor_id
join movies m on m.id=r.movie_id
where a.C_r>2;
# order by a.id;
