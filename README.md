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


## Share
With the analyzed data that have been gathered I created an interactive dashboard in Tableau using KPIs, map, and filters to display the information in a quick and easy to understand visualization.
[Airbnb Thailand Dashboard](https://public.tableau.com/app/profile/pinfar.guo/viz/AirbnbThailand_16827895828170/Dashboard1?publish=yes)

## Act
Based on analysis the following recommendations are provided in terms of where to buy a new rental location:
- top 5 area are - 
- the best room type is entire home/apt.
- the best occupancy rate is 40%+.
- the best price is around ฿2,000 to ฿2,400 per night, with discounts for longer stay (ex: 1 month, 3 month, 6 month, 12 month).

The following 3 listings are the Top 3 listing that are suggested to be used as example to imitate:

 1. 
 2. 
 3. 
 
 Report by: Pin Far Guo
 
