# Netflix Movies And TV Shows Data Analysis using SQL


![Netflix Logo](https://github.com/arshitsharmaa/netflix_sql_project/blob/main/netflix-seeklogo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objective

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The Data for this project is sorced from Kaggle Dataset

-**Dateset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

SQL Netflix project

```sql
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
```

## Business problems and solutions

### 1. Count the number of Movies vs TV Shows

```sql
SELECT type,count(*) as counting 
from netflix
group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the most common rating for movies and TV shows

```sql
WITH max_rating as(
SELECT type,rating,count(*) as max_times_rating
from netflix
group by 1,2
order by 1,3 desc)

select type,rating,max_times_rating from(select *,
rank() over(partition by type order by max_times_rating desc) as rnk
from max_rating) as T
WHERE rnk = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.


### 3. List all movies released in a specific year (e.g., 2020)

```sql
WITH movies_2020 AS (
SELECT * FROM netflix
WHERE type = 'Movie'
)
SELECT * FROM movies_2020
where release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the top 5 countries with the most content on Netflix

```sql
WITH TOP5 AS(
SELECT UNNEST(STRING_TO_ARRAY(country,',')) AS country
FROM netflix
WHERE country <> 'Null'
)
SELECT country ,count(*) as counting from TOP5
group by country
order by counting desc
limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.


### 5. Identify the longest movie

```sql
SELECT * FROM netflix
WHERE type = 'Movie'
AND duration = (SELECT MAX(duration) FROM netflix);
```

**Objective:** Find the movie with the longest duration.


### 6. Find content added in the last 5 years

```sql
SELECT * FROM netflix
WHERE date_added >= current_date - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

```sql
SELECT * FROM netflix
where director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List all TV shows with more than 5 seasons

```sql
SELECT type,title,duration FROM netflix
WHERE type = 'TV Show'
AND cast(split_part(duration,' ',1) as integer) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the number of content items in each genre

```sql
SELECT Total_items,count(*) FROM(
SELECT unnest(string_to_array(listed_in,',')) as Total_items
from netflix) AS T
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

```sql
SELECT country,EXTRACT (year FROM date_added) as year_added,COUNT(*),
ROUND(COUNT(*)::numeric/ (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric *100,2) AS avg_release FROM netflix
WHERE country = 'India'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List all movies that are documentaries

```sql
SELECT title,listed_in FROM netflix
where type = 'Movie' and listed_in Ilike '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find all content without a director

```sql
SELECT * FROM netflix
WHERE director is null;
```

**Objective:** List content that does not have a director.

### 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

```sql
SELECT *FROM(
SELECT * FROM netflix
WHERE type = 'Movie'
AND casts ILIKE '%Salman Khan%') AS T
WHERE date_added >= CURRENT_DATE - INTERVAL '10 years';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

```sql
WITH top10_act AS (
SELECT country,type,
unnest(string_to_array(casts,',')) as casts FROM netflix
WHERE country = 'India' AND type = 'Movie'
)
SELECT casts,count(casts) FROM top10_act
GROUP BY casts
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in  the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

```sql
SELECT type,Content_status,count(*) FROM(
SELECT *,
 CASE WHEN description ILIKE '%kill%' or 
           description ILIKE '%violence%'THEN 'Bad'
	  ELSE 'Good' END AS Content_status
FROM netflix) AS T
GROUP BY 1,2
ORDER BY 1;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


## Findings and Conclusion

- ***Content Distribution:*** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.

- ***Top Most Countries:*** Through analysis we can know about the top 5 countries with most of content on Netflix. This allows Netflix to make decision regarding releasing films in different countries. **Netflix should make stratgies and plans for those countries that are not much avalible on Netflix**. This allows to analyze their preferences and make content accordingly to increase their attraction twards Netflix content. 

- ***Common Ratings:*** Insights into the most common ratings provide an **understanding the preferences of our target audience**. Ratings that are shown most of the times especially ratings that are good for business growth gives a clear understanding of likes of audience But at the same time there can common ratings which shows the dislikes of audience and that should be improved by **making content according to likes of audience. This will lead to long term growth.**

- ***Geographical Insights:*** The top countries and the average content releases by India highlight regional content distribution. This allows the business to categorize the content distribution (Movies and TV shows) that are shown by our audience in India. By doing this **Netflix can make decision that which is better to produce TV shows or Movies in India.**

- ***Top Actors:*** According to data, we analyze that there are 10 actors that are shown in films most of times. In the long term, Netflix should focus on movies/TV Shows with new actors to diversify content and keep audiences engaged. **Netflix should focus on releasing more content performed by young actors, introducing fresh actors may attract younger audiences that increases the number of new audience**.
 
- ***Content Categorization:*** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
