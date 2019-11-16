use imdb2;

##1
# The query below returns the list of directors who work in more than 2 movie genres
  
select d.*, group_concat(g.genre separator ', ') as genres,count(g.genre) as num_genres
from directors d 
join directors_genres g on d.id=g.director_id
group by director_id
having count(g.genre)>=2
order by d.first_name,d.last_name;

##2
# Show which movie got the highest rank in each genre 

create or replace view genre_rank(genre,highest_rank)
as
select g.genre, max(m.rank) as highest_rank
from movies m join movies_genres g 
on m.id=g.movie_id 
group by g.genre;

select * from genre_rank;
  
select  gg.genre, gr.highest_rank, mm.name, mm.year
from genre_rank gr
join movies mm on mm.rank=gr.highest_rank join movies_genres gg on gg.genre=gr.genre and mm.id=gg.movie_id
order by highest_rank desc, genre;

##3
# return directors who were directed more than 1 movie in the last 40 years

select d.*, m.name,round(avg(m.rank),2) as avg_rank, count(*) as num_movies
from movies_directors md 
join directors d on d.id=md.director_id join movies m on m.id=md.movie_id
where m.year>=EXTRACT(YEAR FROM CURRENT_DATE)-40
group by director_id
having count(*)>=(
				select (avg(num_movies))
				from (
						select count(*) as num_movies
						from directors d 
						join movies_directors md on d.id=md.director_id join movies m on m.id=md.movie_id
						group by director_id) ff
					  )
order by d.id;

select * from directors d 
join movies_directors md on d.id=md.director_id join movies m on m.id=md.movie_id where d.id=92;

##4
# show movies where roles were performed by more actresses than actors

select mm.*,fc.Fc, mc.Mc #Mc-Male count, Fc-Female count
from (
	select count(rr2.actor_id) as Fc, rr2.movie_id as mov1
	from roles rr2 join actors aa2 on rr2.actor_id=aa2.id 
    where aa2.gender='F' 
    group by  rr2.movie_id
    ) fc
join (
	select count( rr2.actor_id) as Mc, rr2.movie_id as mov2 
	from roles rr2 join actors aa2 on rr2.actor_id=aa2.id 
    where aa2.gender='M' 
    group by  rr2.movie_id) 
    mc on fc.mov1=mc.mov2
join movies mm on fc.mov1=mm.id 
where fc.Fc>mc.Mc;

##5
# 27522 589713
# Javier Bardem and Penélope Cruz
# The movies that featured this couple on screen
 
select CONCAT(a.first_name,' ',a.last_name) as actor_name,r.role as his_role, CONCAT(p.first_name,' ',p.last_name) as actress_name,p.role as her_role,m.*
from movies m join roles r on r.movie_id=m.id join actors a on a.id=r.actor_id
join(
		select m.*,a.first_name,a.last_name,r.role 
        from movies m join roles r on r.movie_id=m.id join actors a on a.id=r.actor_id
		where a.id= (select id
					from actors
					where first_name='Penélope' and last_name='Cruz')
					) p
on m.id=p.id
where a.id=(select id
			from actors
            where first_name='Javier' and last_name='Bardem');
            
##6
# show movies which got the rank above the avg rank for each genre

select m1.*, g1.genre 
from movies m1
join movies_genres g1 on m1.id=g1.movie_id
where m1.rank>(
				select sc.avg_r
                from (
					select g.genre, avg(m.rank) as avg_r
					from movies m join movies_genres g on m.id=g.movie_id 
					group by g.genre) sc 
				where sc.genre=g1.genre)
order by g1.genre,m1.rank desc;

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

##8
# show movies where number of genres are more than 1 and show it in one row and directors

select m.*, gg.genres, d.* from movies m join
(select movie_id, group_concat(genre separator ', ') as genres, count(genre) as c_g 
from movies_genres group by movie_id) gg
on m.id=gg.movie_id
join (select md.movie_id,
group_concat(d.first_name,' ',d.last_name) as directors
from movies_directors md join directors d 
on md.director_id=d.id group by md.movie_id) d on d.movie_id=m.id
where gg.c_g>=2;

 
##9
#show actors and their movies and roles in the same row
 
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

##10
# show when actor has more than 3 roles last 60 years

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


##ADDITIONAL QUERIES
# (a) how many movies were produced in each genre each year, and show their avg rank

select g.genre, round(avg(m.rank),2) as avg_rank, m.year, count(m.id) as num_of_movies
from movies m join movies_genres g on m.id=g.movie_id
group by g.genre, m.year
having avg_rank<6.5
order by g.genre;


# (b) show directors whose films got rank near to highest rank each year

select d.* from directors d
join movies_directors m_d on d.id=m_d.director_id
join movies m on m.id=m_d.movie_id
where m.rank >= (select max(mm.rank)
from movies mm where mm.year=m.year)-1;

# (c) show movies when number of actors in the movie  is more than its avg in each genre
select m_a.*,mv.*,m_c.* from (
select avg(mc.cc) as cc1, mm.genre 
from (select count(rr.actor_id) as cc, rr.movie_id 
from roles rr group by rr.movie_id) mc
join movies_genres mm on mc.movie_id=mm.movie_id group by mm.genre) m_a
join movies_genres mm2 on m_a.genre=mm2.genre
join movies mv on mv.id=mm2.movie_id
join (select count(rr.actor_id) as ccr, rr.movie_id 
from roles rr group by rr.movie_id) m_c on m_c.movie_id=mm2.movie_id and m_c.movie_id=mv.id
where m_c.ccr > m_a.cc1;

# (d) show number of roles of male and female actors groupped by year

select mm.*,ww.count_F from
(select  m.year , count(distinct r.movie_id, r.role, r.actor_id) as count_M from roles r join actors a on a.id=r.actor_id
join movies m on m.id=r.movie_id
where a.gender='M'
group by m.year ) mm
join (select  m.year , count(distinct r.movie_id, r.role, r.actor_id) as count_F from roles r join actors a on a.id=r.actor_id
join movies m on m.id=r.movie_id
where a.gender='F'
group by m.year ) ww
on mm.year=ww.year;


## (e) show number of roles of male and female actors groupped by year and genre

select mm.*,ww.count_F from
(select m.year ,g.genre, count(distinct r.movie_id, r.role, r.actor_id) as count_M  from roles r join actors a on a.id=r.actor_id
join movies m on m.id=r.movie_id join
movies_genres g on g.movie_id=m.id
where a.gender='M'
group by m.year,g.genre with rollup) mm
join (select  m.year ,g.genre, count( distinct r.movie_id, r.role, r.actor_id) as count_F from roles r join actors a on a.id=r.actor_id
join movies m on m.id=r.movie_id join
movies_genres g on g.movie_id=m.id
where a.gender='F'
group by m.year,g.genre with rollup) ww
on mm.year=ww.year and mm.genre=ww.genre
order by mm.year;


