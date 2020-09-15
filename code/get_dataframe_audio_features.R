
library(spotifyr) # load spotifyR

source("/Users/joellarwood/Dropbox/Joel PhD/SpotifyCredentials.R") # Hard coded to my token

search_get_features <- function(artist, song) {
  
  # this function returns the audio features for a search of a given song and artist

  # search spotify
  search_results <- spotifyr::search_spotify(paste(artist, song), type = "track")


  # get artist name of first result
  spotify_artist <- paste(search_results[[1]][[1]][[3]], 
                          collapse = ",") # allows for multiple artist returns (i.e. featured artists)

  # get song name of first results
  spotify_song <- search_results$name[[1]]

  # get URI of first result
  spotify_uri <- search_results$id[[1]]


  # store meta data
  spotify_meta <- dplyr::bind_cols(spotify_artist, spotify_song, spotify_uri)

  # Make names nice
  colnames(spotify_meta) <- c(
    "artist_result",
    "song_result",
    "uri_result"
  )

  # get features of song

  audio_features <- select(
    spotifyr::get_track_audio_features(
      spotify_meta$uri_result),
      danceability:
      tempo
  ) 
  
  audio_features <- dplyr::bind_cols(
    spotify_meta,
    audio_features
  )

  return(audio_features)
}

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

dataframe_audio_features %>% 
  select(
    id, 
    song_result:tempo
  ) %>% 
  write_rds(
    here::here(
    "data",
    "spotify_features.rds"
    )
  )

