# Get spotify data 

library(tidyverse)
library(spotifyr)


## Load in cleaned data 

for_spotify <- read_rds("data/covid_music_scored_vars.rds") %>% 
  as_tibble() %>% 
  drop_na(music_info_4)


possibly_wrap <- possibly(search_get_features, otherwise = tibble())

dataframe_audio_features <- mutate( 
  for_spotify, 
  audio_features = map2(
    music_info_4, 
    music_info_5, 
    possibly_wrap
  )
) %>% 
  unnest(audio_features) 


spotify_features <- dataframe_audio_features %>% 
  select(id,
         artist_result:tempo)

write_rds(dataframe_audio_features, "data/spotify_added.rds")

write_csv(dataframe_audio_features, "data/spotify_added.csv")

write_rds(spotify_features, "data/spotify_features.rds")




