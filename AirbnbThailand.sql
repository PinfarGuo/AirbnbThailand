/* Airbnb Thailand Project
By Pin Far Guo
Goal - To find location for a new Airbnb rental in Thailand with data
Dataset is from Kaggle - https://www.kaggle.com/datasets/zhenhaosng/airbnb-in-thailand
Dataset contains calendar.csv, listing.csv, neighbourhood.csv, neighbourhood.geojson, reviews.csv
Dataset used will be calendar.csv and listing.csv
*/

-- Initial listing query to determine, which column are most useful
SELECT * 
FROM listings
;
-- id, host_id, host_reponse_rate, host_acceptance_rate, host_identity_verified, 
-- neighbourhood_cleansed, latitude, longitude, property_type, room_type, accommodates, 
-- bathrooms_text, bedrooms, beds, amenities, price, minimum_nights, maximum_nights, 
-- number_of_reviews, first_review, last_review, review_scores_rating, review_scores_location


-- Popular listing locations
SELECT id, neighbourhood_cleansed, property_type, room_type, accommodates, first_review, number_of_reviews, review_scores_location
FROM listings
WHERE review_scores_location IS NOT NULL
ORDER BY number_of_reviews DESC
;
--9918 listings that has areview_scores_location value

-- ROUNDing review score to nearest tenth and limiting numbers of review to 100+
SELECT id, neighbourhood_cleansed, property_type, room_type, accommodates, first_review, number_of_reviews, 
  ROUND(review_scores_location,1) AS review_score
FROM listings
WHERE review_scores_location IS NOT NULL  
  AND number_of_reviews >= 100
ORDER BY review_score DESC
;
-- filtering by number_of_reviews > 100 gives 633 listings
-- the lowest review_score is 3.9

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
-- 34 different locations, Top10 are Vadhana, Khlong Toei, Sathon, Bang Rak, Huai Khwang, Phaya Thai, Ratchathewi, Parthum wan, Phra Nakhon, and Khlong san
-- #1 is Vadhana with 94 listings, 14900 reivews, and a score of 4.7, #4 is Bang Rak with 51 listings and a score of 4.8
-- #10 is Chatu Chak with 18 listings, 3162 reviews, and a score of 4.6, lowest overall is Bueng Kum with 1 listing, 165 reviews, and score of 4.2



-- Property and room type
SELECT DISTINCT room_type, property_type, 
  SUM(number_of_reviews) AS review_num, 
  ROUND(AVG(review_scores_location),1) AS review_score
FROM listings
WHERE review_scores_location IS NOT NULL 
  AND number_of_reviews >=100
GROUP BY room_type,property_type
ORDER BY room_type, review_num DESC
;

SELECT DISTINCT room_type, 
  SUM(number_of_reviews) AS review_num, 
  ROUND(AVG(review_scores_location),1) AS review_score
FROM listings
WHERE review_scores_location IS NOT NULL 
  AND number_of_reviews >=100
GROUP BY room_type
ORDER BY room_type, review_num DESC
;
-- most popular is Entire home/apt at 82,007 reviews
-- interesting is private room is more preferred over hotel room: 19,874 vs 6,737


-- let's check how many amenities each listing have
SELECT id,
  COUNT(value) AS amenities_count, 
  ROUND(AVG(review_scores_rating),1) AS review_score
FROM listings
CROSS APPLY STRING_SPLIT(amenities,',')
GROUP BY id
ORDER BY amenities_count DESC
;


-- let's see what is a good price for the top 10 area's
--Vadhana,Khlong Toei,Sathon,Bang Rak,Phaya Thai,Huai Khwang,Ratchathewi,Parthum Wan,Khlong San,Chatu Chak
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



-- Calendar to link with listings
SELECT count(*)
FROM calendar
;
-- calendar has 5,786,345 rows which is why I used SQL because Excel was not able to support that many rows.

SELECT count(*)
FROM calendar
WHERE price < 10000
;
-- filtered rows by $10k because higher price than this does not make sense. I spot checked multiple rentals it seems like possible renter pricing mistake.
-- 5,657,753 rows with price < 10k

SELECT ca.*
FROM listings AS li
JOIN calendar AS ca
  ON li.id = ca.listing_id
WHERE li.price < 10000 
  AND li.review_scores_rating IS NOT NULL
  AND listing_id = '8769212'
;
-- used to spot check found multiple anomalies.
-- 1. low end places are priced really high even if pricing mistake by renter, mainly price of $10k+
-- 2. on available days its price low, around $2,400 and on unavailable days price high around $140k
-- 


SELECT DISTINCT ca.listing_id, available, 
  COUNT(date) AS count_available, ca.maximum_nights
INTO #temp_calendar
FROM listings AS li
JOIN calendar AS ca
  ON li.id = ca.listing_id
WHERE li.price < 10000 
  AND li.review_scores_rating IS NOT NULL
  AND available = 0
GROUP BY ca.listing_id, available, ca.maximum_nights
ORDER BY ca.listing_id, available
;
-- 9,258 listings 
--- price changes here is legit, most likely due to discount FROM long stay
--- note: that price increASes happens during december through feburary timeframe because of high seASon
-- note: turn this into a temp table so that I can filter the count_available info to see which listings has most bookings
-- temp table #temp_calendar created


SELECT *
FROM #temp_calendar
WHERE count_available > 300
  AND maximum_nights = 1125
ORDER BY count_available DESC
;
-- 905 listings with max nights = 1125

-- lets see how calendar info relates to reviews
-- with DISTINCT there are 9,208 rows, with number of reviews greater than 100 its 612 rows
-- so there are over 612 listings that hAS bookings in new year already
-- in order to not be too biAS I filter bASed on other stuff and got back 5,879 rows
SELECT DISTINCT li.id, neighbourhood_cleansed, number_of_reviews--, li.price
FROM listings li
JOIN calendar ca
  ON li.id = ca.listing_id
WHERE li.price < 10000 
  AND li.review_scores_rating IS NOT NULL
  AND available = 0
  AND (number_of_reviews >99 
    OR (number_of_reviews >=3 
      AND (host_response_rate >='50%' AND host_response_rate != 'N/A' OR host_response_rate = '100%')
      AND last_review >= CONVERT (datetime, '1/1/2020')
  )
 )
ORDER BY number_of_reviews DESC, neighbourhood_cleansed
;

-- with 5,879 DISTINCT IDs lets see how many belong to each location
SELECT DISTINCT neighbourhood_cleansed, 
  COUNT(available) AS bookings, 
  AVG(ca.maximum_nights) AS avg_max_nights--, li.price
FROM listings li
JOIN calendar ca
  ON li.id = ca.listing_id
WHERE li.price < 10000 and li.review_scores_rating IS NOT NULL
  AND available = 0
  AND ca.maximum_nights < 3000
  AND (number_of_reviews >99 
    OR (number_of_reviews >=3 
      AND (host_response_rate >='50%' AND host_response_rate != 'N/A' OR host_response_rate = '100%')
      AND last_review >= CONVERT(datetime, '1/1/2020')
  )
 )
GROUP BY neighbourhood_cleansed
ORDER BY bookings DESC, neighbourhood_cleansed
;
-- top 10 by calendar bookings: Khlong Toei	167756, Vadhana	155964, Huai Khwang	81781, Ratchathewi	60093, Bang Rak	49729, Sathon	37517,
--- Parthum Wan	27309, Phaya Thai	27198, Phra Khanong	24249, Bang Na	23400
-- there is a huge drop off in terms of 1st place and 10th place
-- most of the top 10 has an average max nights of around 900 to 1000

-- Table with all columns required to pull into Tableau
SELECT id, neighbourhood_cleansed, longitude, latitude, property_type, room_type, accommodates, 
 number_of_reviews,first_review, last_review, review_scores_rating, review_scores_location,  price, maximum_nights, host_response_rate
FROM listings
WHERE price < 10000 and review_scores_rating IS NOT NULL
  AND maximum_nights < 3000
  AND (number_of_reviews >99 
    OR (number_of_reviews >=3 
      AND (host_response_rate >='50%' AND host_response_rate != 'N/A' OR host_response_rate = '100%')
      AND last_review >= CONVERT(datetime, '1/1/2020')
  )
 )
ORDER BY number_of_reviews desc
;
-- This return over 6,000 listings out of 15,000

SELECT DISTINCT listing_id, 
  COUNT(available) AS avail_count, 
  (COUNT(available)/365.0) * 100 AS occupancy_rate
FROM listings li
JOIN calendar ca
  ON li.id = ca.listing_id
WHERE li.price < 10000 and li.review_scores_rating IS NOT NULL
  AND available = 0
  AND ca.maximum_nights < 3000
  AND (number_of_reviews >99 
    OR (number_of_reviews >=3 
      AND (host_response_rate >='50%' AND host_response_rate != 'N/A' OR host_response_rate = '100%')
      AND last_review >= CONVERT(datetime, '1/1/2020')
  )
 )
GROUP BY listing_id
ORDER BY avail_count desc
;
-- 5875 listings that have 