# Airbnb Thailand
![CoverPage](https://github.com/PinfarGuo/AirbnbThailand/blob/main/AirbnbThailand_CoverPage.jpg)

## Ask
The business task for this project/case study is to find a new Airbnb rental in Thailand using data.
List of questions related to this task are:

 - what is a good location for a new rental?
 - how to determine if there is a good location?
 - which room type is the best?
 - what is a good price for a new rental?
 - what is a good occupancy rate?

## Prepare
The data prepared for this project/case study is from [Kaggle](https://www.kaggle.com/datasets/zhenhaosng/airbnb-in-thailand). The dataset size is about 427MB with the following files:

 - calendar.csv (5 million+ unique values)
 - listings.csv (15K+ unique values)
 - neighbourhood.csv (50 unique values)
 - neighbourhodd.geojson (1.86MB size)
 - reviews.csv (73K+ unique values)

Digging through the data it can be seen that not all files were required for this task, thus only specific files was selected.

 - calendar.csv - contains info about availability, which we can use for occupation info. Will use.
 - listings.csv - contains info about listings, reviews, price, location, room type. Will use.
 - neighbourhood.csv - only contain neighbourhood info, which is already contained in listings.csv. Will not use.
 - neighbourhood.geojson - contains info in regards to geo location, which can be used for map, but info longitude and latitude info is already in listings.csv. Will not use.
 - reviews.csv - contains review, but no valuable quantitative info linking to listing. Will not use.

## Process
After we have our files for calendar.csv and listings.csv we can start the next step, which is processing the info.
Because the calendar.csv have over 5 million+ rows Excel could not be used, thus data was imported into SQL database to extract, transform, and load data.

### Extract
Data from calendar.csv and listings.csv where extracted and loaded into SQL Server, which can handle the large dataset (5 million+) via respective tables calendar and listing.

### Transform
Listings:
 - remove unused columns, going from original 75 columns down to 15 usable columns.
 - added additional "Grade" column to help separate rentals into 5 rankings based on numbers of reviews and review score.

calendar:
- created query to consolidate listings available info into new usable column "occupancy rate". 
- going from 5 million+ rows down to around 6,000. 
 
### load
With the transformed data analysis can be done via querying and then extracted from SQL Server into Microsoft Excel files, which can then be loaded into Tableau.
Excel files created to load into Tableau are "listings_cleaned" and "occupancy_rate".

## Analyze
Based on Analysis in Excel, SQL, and Tableau:
- top 5 area are - 'Vadhana', 'Khlong Toei', 'Parthum Wan', 'Bang Rak', 'Phaya Thai'
```sql
SELECT DISTINCT neighbourhood_cleansed, 
  COUNT(id) AS listings, 
  SUM(number_of_reviews) AS review_num, 
  ROUND(AVG(review_scores_location),1) AS avg_score
FROM listings
WHERE review_scores_location IS NOT NULL  
  AND number_of_reviews >= 100
GROUP BY neighbourhood_cleansed
ORDER BY review_num DESC
;
```
[TopLocations](https://github.com/PinfarGuo/AirbnbThailand/blob/main/TopLocations.jpg)
- the best room type is entire home/apt.
```sql
SELECT DISTINCT room_type, 
  SUM(number_of_reviews) AS review_num, 
  ROUND(AVG(review_scores_location),1) AS review_score
FROM listings
WHERE review_scores_location IS NOT NULL 
  AND number_of_reviews >=100
GROUP BY room_type
ORDER BY review_num DESC
;
``` 
[TopRoomType](https://github.com/PinfarGuo/AirbnbThailand/blob/main/TopRoomType.jpg)
- the best occupancy rate is 39%+.
```sql
SELECT DISTINCT neighbourhood_cleansed, AVG(oc.occupancy_rate) as occupancy
FROM listings li
JOIN #temp_occupancy_rate oc
ON li.id = oc.listing_id
WHERE neighbourhood_cleansed IN ('Vadhana','Khlong Toei','Sathon','Bang Rak','Phaya Thai','Huai Khwang','Ratchathewi','Parthum Wan','Khlong San','Chatu Chak')
GROUP BY neighbourhood_cleansed
ORDER BY occupancy DESC
;
``` 
[TopOccupancyRate](https://github.com/PinfarGuo/AirbnbThailand/blob/main/TopOccupancyRate.jpg)
- the best price is around ฿1,200 to ฿2,400 per night, with discounts for longer stay (ex: 1 month, 3 month, 6 month, 12 month).
```sql
SELECT neighbourhood_cleansed, 
  SUM(number_of_reviews) AS total_reviews, 
  ROUND(AVG(price),2) AS avg_price
FROM listings
WHERE review_scores_location IS NOT NULL  
  AND number_of_reviews >= 100
  AND price < 10000
  AND neighbourhood_cleansed IN ('Vadhana','Khlong Toei','Sathon','Bang Rak','Phaya Thai','Huai Khwang','Ratchathewi','Parthum Wan','Khlong San','Chatu Chak')
GROUP BY neighbourhood_cleansed
ORDER BY total_reviews DESC,neighbourhood_cleansed,avg_price DESC
;
``` 
[TopPrice](https://github.com/PinfarGuo/AirbnbThailand/blob/main/TopPrice.jpg)

## Share
With the analyzed data that have been gathered I created an interactive dashboard in Tableau using KPIs, map, and filters to display the information in a quick and easy to understand visualization.
<div class='tableauPlaceholder' id='viz1682944127968' style='position: relative'><noscript><a href='#'><img alt='Dashboard 1 ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ai&#47;AirbnbThailand_16827895828170&#47;Dashboard1&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='AirbnbThailand_16827895828170&#47;Dashboard1' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Ai&#47;AirbnbThailand_16827895828170&#47;Dashboard1&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /><param name='language' value='en-US' /><param name='filter' value='publish=yes' /></object></div>                <script type='text/javascript'>                    var divElement = document.getElementById('viz1682944127968');                    var vizElement = divElement.getElementsByTagName('object')[0];                    if ( divElement.offsetWidth > 800 ) { vizElement.style.width='1200px';vizElement.style.height='727px';} else if ( divElement.offsetWidth > 500 ) { vizElement.style.width='1200px';vizElement.style.height='727px';} else { vizElement.style.width='100%';vizElement.style.height='1077px';}                     var scriptElement = document.createElement('script');                    scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    vizElement.parentNode.insertBefore(scriptElement, vizElement);                </script>
[Airbnb Thailand Dashboard](https://public.tableau.com/app/profile/pinfar.guo/viz/AirbnbThailand_16827895828170/Dashboard1?publish=yes)

## Act
Based on analysis the following recommendations are provided in terms of where to buy a new rental location:

The following 3 listings are the Top 3 listing that are suggested to be used as example to imitate:
 1. [Listing 1](https://www.airbnb.com/rooms/20869092): 1224 reviews with review score of 4.89 in Phaya Thai for ฿1,571 for entire home/apt.
 2. [Listing 2](https://www.airbnb.com/rooms/6013487): 477 reviews with review score of 4.85 in Khlong Toei for ฿2,329 for hotel room.
 3. [Listing 3](https://www.airbnb.com/rooms/7537579): 382 reviews with review score of 4.88 in Vadhana for ฿1,250 for entire home/apt.
 
 ## Links
 Report by: Pin Far Guo
 - Dataset: [Kaggle](https://www.kaggle.com/datasets/zhenhaosng/airbnb-in-thailand)
 - SQL: [SQL Queries](https://github.com/PinfarGuo/AirbnbThailand/blob/main/AirbnbThailand.sql)
 - Tableau: [Tableau Dashboard](https://public.tableau.com/app/profile/pinfar.guo/viz/AirbnbThailand_16827895828170/Dashboard1?publish=yes)
