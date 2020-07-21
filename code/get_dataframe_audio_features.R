test_tibble <- tibble::tribble( # this is so I can test the function
  ~song, ~artist, ~pid,
  "Tangled, Content", "Luca Brasi", 1,
  "Reviews", "Bugs", 2, 
  "Love Will Tear Us Apart", "Joy Division", 3, 
  "noafaa", "asfdas", 6,
  "Or Nah", "Ty Dolla $ign", 4,
  "1996", "The Wombats", 5,
)

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

search_luca <- spotifyr::search_spotify(paste("Tangled, Content", "Luca Brasi"), type = "track")

get_luca <- search_get_features("Tangled, Content", "Luca Brasi")

joy_search <- spotifyr::search_spotify(paste("Love will tear us apart", "Joy Division"), type = "track")

get_joy <- search_get_features("Love will tear us apart", "Joy Division")

search_dolla <- spotifyr::search_spotify(paste("Or Nah", "Ty Dolla $ign"), type = "track")
  

get_dataframe_audio_features <- function(data, artist, song, nested = FALSE) {
  
  # This function gets the audio features for songs listened in a dataframe
  # wrap for when there is no result 
  possibly_wrap <- possibly(search_get_features, otherwise = tibble())
  
  # loop through frame and return data frame with audio features
  
  dataframe_audio_features <- mutate( 
    data, 
    audio_features = map2(
      artist, 
      song, 
      possibly_wrap
    )
  )
  
  # return results as columns where each row is each song listed in original dataframe
  if(nested == FALSE){
    dataframe_audio_features <- tibble::as_tibble(
      tidyr::unnest(dataframe_audio_features,
                    cols = audio_features)
    )
  }
  
  return(dataframe_audio_features)
}


## Test function using test dataframe

test_rtn_false <- get_dataframe_audio_features(
  test_tibble,
  artist,
  song
)
