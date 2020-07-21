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

write_rds(dataframe_audio_features, "data/spotify_added.rds")
