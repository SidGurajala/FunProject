# This is data taken from Kaggle!
us_counties_covid <- read.csv("./us-counties.csv", stringsAsFactors= FALSE)

library(dplyr)
library(ggplot2)
library(maps)

#WASHINGTON COVID 19 CASES MAP

#This filters the kaggle data set down to washington state 
# and the most recent date from NYT (May 7th)
washington_df <- us_counties_covid %>% 
                  filter(state == "Washington" & date == "2020-05-07") %>% 
                  mutate(county = tolower(county)) %>% 
                  group_by(county) %>% 
                  summarize(
                    cases = cases,
                    deaths = deaths)

#This loads map data from washington state (long, lat, and counties(listed as subregion))
wash_counties <- map_data("county", "Washington") %>% 
                    rename(county = subregion)

#Here I'm joining the washington state covid 19 deaths and cases data 
#that I summarized with the map data
# A warning: not all counties in the wash_counties data frame are in the 
# washington_df data frame; this will create NA values for cases/deaths at those coordinates
# I've chosen to leave them as indications that the NYT doesn't have data for those counties
wash_counties_deaths_cases <- left_join(wash_counties, washington_df)

#Here I'm taking the joined data frame and inputting latitude, longitude coordinates
#and the fill, which is cases. You could also pick deaths here.
wash0 <- ggplot(data = wash_counties_deaths_cases,
             mapping = aes(x = long, y = lat, group = group, fill = cases))

#Here I've taken the latitude and longitude coordinates and actually applied 
#them to a projection of washington state; this will give you a heat map of cases
#I found this online as well, it helped with the coord_map  
wash1 <- wash0 + geom_polygon(color = "ivory", size = 0.3) +
  coord_map(projection = "albers", lat0 = 45.55, lat1 = 49)

#This is a simple add on that helps formats your maps; I found this
#on stack overflow and it removes axis lables and lat and long coordinates
no_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

#Here I've put it together and formatted with scale_fill_gradient to 
#make a heat map that goes from white to red; this is optional
wash2 <- wash1 + scale_fill_gradient(low = "white", high = "#F21717") +
  labs(title = "Washington Covid Cases by County") + no_axes

#this is the finished project with a heat map legend that reads cases
wash_covid_map <- wash2 + labs(fill = "Cases")


#Here's an integrated example using California Data

#CALIFORNIA COVID 19 CASES MAP
california_df <- us_counties_covid %>% 
  filter(state == "California" & date == "2020-05-07") %>% 
  mutate(county = tolower(county)) %>% 
  group_by(county) %>% 
  summarize(
    cases = cases,
    deaths = deaths)

cali_counties <- map_data("county", "California") %>% 
  rename(county = subregion)

cali_counties_deaths_cases <- left_join(cali_counties, california_df)

cali0 <- ggplot(data = cali_counties_deaths_cases,
             mapping = aes(x = long, y = lat, group = group, fill = deaths))

cali_covid_map <- cali0 + geom_polygon(color = "ivory", size = 0.3) +
  coord_map(projection = "albers", lat0 = 32, lat1 = 42) +
  labs(title = "California Covid Deaths by County") +
  scale_fill_gradient(low = "white", high = "#660033") +
  no_axes +
  labs(fill = "Deaths")

