# merge files 

scores <- read_rds(
  here::here(
    "data",
    "covid_music_scored_vars.rds"
  )
)

spotify <- read_rds(
  here::here(
    "data",
    "spotify_features.rds"
  )
)


spotify_added <- left_join(
  scores,
  spotify,
  by = "id"
) %>% 
  filter(prop_miss_all < .5)

write_rds(
  spotify_added,
  here::here(
    "data",
    "spotify_added.rds"
  )
)

write_csv(
  spotify_added,
  here::here(
    "data",
    "spotify_added.csv"
  )
)

