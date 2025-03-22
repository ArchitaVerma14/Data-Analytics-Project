use movie_recommendation;
CREATE TABLE rating (
	userId INT,
    movieId INT,
    rating FLOAT,
    timestamp timestamp
);
select * from movie;
CREATE TABLE genome_tags (
	tagId INT,
    tag varchar(255)
);
select * from genome_scores;
CREATE TABLE genome_scores (
    movieId INT,
	tagId INT,
    relevance double
);
CREATE TABLE tag (
    userId INT,
    movieId INT,
	tag varchar(255),
    timestamp timestamp
);
select * from movie;
CREATE TABLE link (
    movieId INT,
	imdbId int,
    tmdbId int
);
select * from link;
#Find the Top 10 Highest-Rated Movies
select m.movieId,m.title, AVG(r.rating) as AVG_Rating
from movie m
join rating r on m.movieId=r.movieId
group by m.movieId,m.title
order by AVG_Rating desc
limit 10;

#List Movies by Genre (Using Tags or Genome Tags)
select movieId,title, genres 
from movie 
order by genres;

#Recommend Movies Similar to a User’s Top-Rated Ones
select AVG(r.rating) as avg_rating,r.movieId,m.title
from rating r
join movie m on r.movieId=m.movieId
where r.userId=1
group by r.movieId,m.title
order by avg_rating desc;

#Query to Find Similar Movies Based on Genres
select distinct m2.title,m2.genres
from movie m1
join movie m2 on m1.genres=m2.genres
where m1.movieId in(
     select movieId
     from rating
     where userId=1
     order by rating desc
 )
 and m1.movieId<>m2.movieId #Exclude already watched movie
 order by m2.title;
 select * from tag;
 select * from genome_tags;
 
 #Show Movies That Share Similar Tags
 select distinct m2.title,t2.tag
 from tag t1
 join tag t2 on t1.tag=t2.tag
 join movie m1 on t1.movieId=m1.movieId
 join movie m2 on t2.movieId=m2.movieId
 where t1.movieId in(
    select movieId
    from rating
    where userId=1
    order by rating desc
 )
 and t1.movieId<>t2.movieId
 order by t2.tag,m2.title;
 #Rank genres by average rating.
 select m.genres, avg(r.rating) as avg_rating
 from movie m 
 join rating r on m.movieId=r.movieId
 group by m.genres
 order by avg_rating desc;
#Find the most popular tags for each genre.
select m.genres,t.tag,count(*) as tag_count
from movie m
join tag t on m.movieId=t.movieId
group by m.genres,t.tag
order by m.genres, tag_count desc;
select * from genome_scores;
#Identify movies with the highest relevance scores for a particular tag.
select m.movieId,m.title,t.tag,max(gs.relevance) as highest_relevance
from movie m
join genome_scores gs on m.movieId=gs.movieId
join genome_tags t on gs.tagId=t.tagId
WHERE t.tag = 'dark'  -- Replace with any tag
group by m.movieId,m.title,t.tag
order by highest_relevance desc;
#Calculate tag similarity between movies.
select gs1.movieId as movie1, gs2.movieId as movie2,
  sum(least(gs1.relevance,gs2.relevance)) as similarity_score
from genome_scores gs1
join genome_scores gs2 on gs1.tagId=gs2.tagId
  and gs1.movieId< gs2.movieId
group by gs1.movieId,gs2.movieId
order by similarity_score desc;
#combined tag similarity + user preferences for a more personalized recommendation.
with UserTopMovies as(
  select r.movieId, avg(r.rating) as avg_rating
  from rating r
  where r.userId=12
  group by r.movieId
  having avg_rating >=4
)
select m2.movieId,m2.title,
  sum(least(gs1.relevance,gs2.relevance)) as similarity_score, 
  coalesce(avg(r.rating),0) as avg_rating 
from UserTopMovies ut
join genome_scores gs1 on ut.movieId=gs1.movieId
join genome_scores gs2 on gs1.tagId=gs2.tagId
join movie m2 on gs2.movieId=m2.movieId
left join rating r on m2.movieId=r.movieId
where gs1.movieId<>gs2.movieId
group by m2.movieId,m2.title
order by similarity_score desc, avg_rating desc;
#Find the Most Popular Movies Based on IMDb/TMDb Matches
select m.movieId,m.title,l.imdbId,l.tmdbId, count(r.userId) as total_ratings
from link l
join rating r on l.movieId=r.movieId
join movie m on l.movieId=m.movieId
group by m.movieId,m.title,l.imdbId,l.tmdbId
order by total_ratings desc;

  

