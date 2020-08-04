# Get lyrics

library(genius)
library(tidyverse)

spotify_lyrics <- here::here(
  "data",
  "spotify_added.rds"
) %>% 
  read_rds() %>% 
  genius::add_genius(
    artist = artist_result,
    title = song_result,
    type = "lyrics"
  )

write_rds(
  spotify_lyrics, 
  here::here(
    "data",
    "spotify_lyrics.rds"
  )
)
