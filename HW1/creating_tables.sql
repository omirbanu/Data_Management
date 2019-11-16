use imdb2;
create table movies like imdb0.movies;
create table movies_directors like imdb0.movies_directors;
create table movies_genres like imdb0.movies_genres;
create table directors like imdb0.directors;
create table directors_genres like imdb0.directors_genres;
create table roles like imdb0.roles;
create table actors like imdb0.actors;
#drop table roles;

ALTER table roles
ADD FOREIGN KEY fk1(actor_id)
REFERENCES actors(id);
alter table roles
add foreign key fk11(movie_id)
references movies(id);
ALTER table directors_genres
ADD FOREIGN KEY fk2(director_id)
REFERENCES directors(id);

alter table movies_directors
add foreign key fk3(director_id)
references directors(id);

alter table movies_directors
add foreign key fk4(movie_id)
references movies(id);

alter table movies_genres
add foreign key fk5(movie_id)
references movies(id);



insert into movies select * from imdb0.movies where imdb0.movies.rank is not NULL limit 9000;



insert into movies_genres select g.movie_id, g.genre
from imdb0.movies_genres g join movies m on g.movie_id=m.id;


insert into directors
select distinct d.* from imdb0.directors d;

insert into movies_directors select d.director_id,d.movie_id 
from imdb0.movies_directors d join movies m on d.movie_id=m.id join directors f on f.id=d.director_id;

insert into directors_genres
select d.* from imdb0.directors_genres d join directors t on d.director_id=t.id;


#insert into actors
#select * from imdb0.actors;

#insert into roles
#select d.* from imdb0.roles d join movies m on d.movie_id=m.id;


insert into actors
select distinct d.* from imdb0.actors d join imdb0.roles r on r.actor_id=d.id join movies m on m.id=r.movie_id;

insert into roles
select d.* from imdb0.roles d join movies m on d.movie_id=m.id join actors a on a.id=d.actor_id and d.role!='';
#select count(distinct actor_id) from roles;
#select count(distinct id) from actors;
#select count(distinct r.actor_id) from actors d join roles r on r.actor_id=d.id;




