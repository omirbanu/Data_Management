/*
0. Downloading the data from the website:
https://relational.fit.cvut.cz/dataset/IMDb-->
originally taken from --> http://kt.ijs.si/janez_kranjc/ilp_datasets/

Steps of importing the data:
1. REDUCING the data by the creation of a new schema - imdb2, a reduced version of imdb
2. creation of tables in the new reduced schema with the same structure as tables in the original schema
2. Change the storage engine for the DBMS MySQL to InnoDB
3. Add constraints, FOREIGN keys (FK)...primary already been there (actors, directors and movies)
4. Reverse engineering- Data model EER(Entity Relationship) model

*/

# (1) Use new reduced schema
use imdb2; 

# (2) creation of tables in the new reduced schema with the same structure as tables in the original schema

create table movies like imdb.movies;
create table movies_directors like imdb.movies_directors;
create table movies_genres like imdb.movies_genres;
create table directors like imdb.directors;
create table directors_genres like imdb.directors_genres;
create table roles like imdb.roles;
create table actors like imdb.actors;

# (3) Reducing the data by conditions and eliminating records where values are NULL

insert into movies select * from imdb.movies where imdb.movies.rank is not null and imdb.movies.id between 10000 and 80000;

insert into movies_genres select g.movie_id, g.genre
from imdb.movies_genres g join movies m on g.movie_id=m.id;

insert into directors
select distinct d.* from imdb.directors d;

insert into movies_directors select d.director_id,d.movie_id 
from imdb.movies_directors d join movies m on d.movie_id=m.id join directors f on f.id=d.director_id;

insert into directors_genres
select d.* from imdb.directors_genres d join directors t on d.director_id=t.id;

insert into actors
select * from imdb.actors; 

insert into roles
select * from imdb.roles where imdb.roles.movie_id between 10000 and 80000 and imdb.roles.role!='';

select count(*) from actors; #195 485
select count(*) from roles; #
select count(*) from movies; #12 496
select count(*) from movies_genres; #19 727
select count(*) from movies_directors; #13 203
select count(*) from directors; #86 880
select count(*) from directors_genres; #156 562

SET SQL_SAFE_UPDATES = 0;
delete from actors where id not in (select actor_id from roles);
select count(*) from actors;

select  count(*) from roles where movie_id not in (select id from movies);
delete from roles where movie_id not in (select id from movies);
delete from roles where movie_id not in (select movie_id from movies_genres);
select count(*) from roles;

# (4) Add constraints, FOREIGN keys (FK)

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



