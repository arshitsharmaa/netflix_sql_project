-- Netflix project

 DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
  show_id VARCHAR(50),
  type VARCHAR(50),
  title VARCHAR(250),
  director VARCHAR(550),
  casts VARCHAR(1050),
  country VARCHAR(550),
  date_added DATE,
  release_year INT,
  rating VARCHAR(15),
  duration VARCHAR(15),
  listed_in VARCHAR(250),
  description VARCHAR(550)
);

SELECT * FROM netflix;

-- verify total rows
SELECT COUNT(*) FROM netflix;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type,count(*) as counting 
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

WITH max_rating as(
SELECT type,rating,count(*) as max_times_rating
from netflix
group by 1,2
order by 1,3 desc)

select type,rating,max_times_rating from(select *,
rank() over(partition by type order by max_times_rating desc) as rnk
from max_rating) as T
WHERE rnk = 1;



-- 3. List all movies released in a specific year (e.g., 2020)

WITH movies_2020 AS (
SELECT * FROM netflix
WHERE type = 'Movie'
)
SELECT * FROM movies_2020
where release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

WITH TOP5 AS(
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS country
FROM netflix
WHERE country <> 'Null'
)
SELECT country ,count(*) as counting from TOP5
group by country
order by counting desc
limit 5;


-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);


-- 6. Find content added in the last 5 years
SELECT * FROM netflix
WHERE date_added >= current_date - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
where director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT type,title,duration FROM netflix
WHERE type = 'TV Show'
AND cast(split_part(duration,' ',1) as integer) > 5;


-- 9. Count the number of content items in each genre

SELECT Total_items,count(*) FROM(
SELECT unnest(string_to_array(listed_in,',')) as Total_items
from netflix) AS T
GROUP BY 1
ORDER BY 2 DESC;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!


SELECT country,EXTRACT (year FROM date_added) as year_added,COUNT(*),
ROUND(COUNT(*)::numeric/ (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric *100,2) AS avg_release FROM netflix
WHERE country = 'India'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5



-- 11. List all movies that are documentaries

SELECT title,listed_in FROM netflix
where type = 'Movie' and listed_in Ilike '%Documentaries%';

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *FROM(
SELECT * FROM netflix
WHERE type = 'Movie'
AND casts ILIKE '%Salman Khan%') AS T
WHERE date_added >= CURRENT_DATE - INTERVAL '10 years';

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

WITH top10_act AS (
SELECT country,type,
unnest(string_to_array(casts,',')) as casts FROM netflix
WHERE country = 'India' AND type = 'Movie'
)
SELECT casts,count(casts) FROM top10_act
GROUP BY casts
ORDER BY 2 DESC
LIMIT 10;

-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT type,Content_status,count(*) FROM(
SELECT *,
 CASE WHEN description ILIKE '%kill%' or 
           description ILIKE '%violence%'THEN 'Bad'
	  ELSE 'Good' END AS Content_status
FROM netflix) AS T
GROUP BY 1,2
ORDER BY 1;
