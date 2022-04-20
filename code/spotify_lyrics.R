# Get lyrics

library(genius)
library(tidyverse)
library(tidytext)

spotify_lyrics <- here::here(
  "data",
  "spotify_features.rds"
) %>% 
  read_rds() %>% 
  genius::add_genius(
    artist = artist_result,
    title = song_result,
    type = "lyrics"
  )


lyrics <- spotify_lyrics %>% 
  select(artist_result,
         song_result,
         track_title,
         line,
         lyric
         ) %>% 
  tidytext::unnest_tokens(
    output = word,
    input = lyric
  ) %>% 
  anti_join(tidytext::stop_words) %>% 
  inner_join(tidytext::get_sentiments("afinn")) %>% 
  group_by(track_title) %>% 
  summarise(
    sentiment = mean(value)
  )


write_rds(
  lyrics, 
  here::here(
    "data",
    "lyrics.rds"
  )
)
