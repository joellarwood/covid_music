
#################################################################
##                    Extract relevant data                    ##
#################################################################


# load packages -----------------------------------------------------------

library(haven)
library(stringr)
library(readr)
library(lubridate)
library(MissMech)
library(labelled)
library(sjlabelled)
library(janitor)
library(dplyr)
library(forcats)
library(naniar)
library(tidyr)
library(mice)

# Import data  ------------------------------------------------------------

# This is hardcoded to my dropbox
raw_survey <- haven::read_sav(
  "/Users/joellarwood/Dropbox/Joel PhD/covid_music/raw_wellbeing_survey.sav"
  ) %>% 
  janitor::clean_names()


# Get variable labels and print to table 

raw_survey %>% 
  labelled::look_for() %>% 
  knitr::kable(format = "html") %>% 
  kableExtra::kable_styling()

# Select variables --------------------------------------------------------

# Create vector of variables that are to be kept 

variable_keep <- raw_survey %>% 
  select(
  start_date, # date survey started
  end_date, # date ended 
  recorded_date, # date data recorded
  gender, #gender
  age, # age
  enrolment_school, #enrolment school
  student_status, #international v domestic
  citizenship, # citizenship
  ethnic_group, #ethnicity
  current_circumstance, # resticitions
  covid_19_stress_1:covid_19_stress_13, # COVID stress
  emotional_responses_1:emotional_responses_18, #COVID emotional response
  coping_strategies_1:coping_strategies_15, # Coping strategies 
  swemwbs_1:swemwbs_7, # short warrick endenburgh wellbeing scale
  psy_check_1:psy_check_20, #psycheck
  music_info_4:music_info_5 # music info
  ) %>% 
  filter(
    !str_detect(citizenship,
                "Test")
  ) %>% 
  rename(
    "exercise" = coping_strategies_1,
    "Music" = coping_strategies_2,
    "Chores" = coping_strategies_3,
    "Sleep" = coping_strategies_4,
    "Control_Thoughts" = coping_strategies_5,
    "Evalaute_Situation" = coping_strategies_6,
    "Perspective_Taking" = coping_strategies_7,
    "Avoid_Thing" = coping_strategies_8,
    "Alone" = coping_strategies_9,
    "Relaxation_Techniques" = coping_strategies_10,
    "Stress_Management" = coping_strategies_11,
    "Religious_Activity" = coping_strategies_12,
    "Change_Location" = coping_strategies_13,
    "Call_Someone" = coping_strategies_14,
    "Internet" = coping_strategies_15
  ) %>%
  mutate_at(
    .vars = vars(gender, 
                 current_circumstance,
                 student_status,
                 enrolment_school),
    .funs = sjlabelled::as_label
  ) %>% 
  mutate(  
    age = as.numeric(age), #make age numeric
    date = lubridate::ymd_hms(recorded_date) %>%
      lubridate::round_date(unit = "day")
  ) %>% 
  filter(date != ymd(20200414)) %>% 
  mutate_at( # subtract 1 for psycheck so that no = 0 
    vars(contains("psy_check")), 
    ~ . - 1
  ) %>% 
  naniar::add_prop_miss() %>%  # get proportion of missing data for each participant
  tibble::rowid_to_column("id") %>% 
  naniar::replace_with_na( # make incorrect ages NA
    replace = list(
      age = c(0, 1, 2, 1998, 99, 999)
    )
  ) %>%  
  janitor::clean_names()



# write this file 
write_rds(variable_keep, 
          "data/reduced_international_student_survey.rds")

# Simple data frame -------------------------------------------------------

# The data frame only contains final scores 

scores_only <- variable_keep %>% 
  transmute(
    id = id,
    covid_stress = select(. ,
                          contains("covid")) %>% rowSums(),
    emotional_response = select(.,
                                contains("emotional")) %>% rowSums(),
    wellbeing = select(., 
                       contains("swemwbs")) %>% rowSums(),
    psycheck = select(., 
                      contains("psy")) %>% rowSums()
  ) 

# Add coping strategies

scores_coping <- variable_keep %>% 
  select(
    -contains("psy"),
    -contains("swemwbs"),
    -contains("covid"),
    -contains("emotional"),
    -prop_miss_all
  ) %>% 
  full_join(scores_only) %>% 
  naniar::add_prop_miss() 

# write this file 

write_rds(
  scores_coping, 
  "data/covid_music_scored_vars.rds"
)

# Missing data anlyses ----------------------------------------------------

naniar::vis_miss(scores_coping)

# MissMech::TestMCARNormality(
#   data = select_if(variable_keep, is.numeric)
# )



# write condensed survey --------------------------------------------------

write_csv(
  atempted_survey,
  "reduced_international_student_survey.csv"
)
  
write_rds(  atempted_survey,
            "reduced_international_student_survey.rds"
)
 

tmp <-   raw_survey %>% 
  mutate_at(
    .vars = vars(gender, 
                 current_circumstance,
                 student_status,
                 enrolment_school),
    .funs = sjlabelled::as_label
  )
