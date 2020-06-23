
#################################################################
##                    Extract relevant data                    ##
#################################################################


# load packages -----------------------------------------------------------

library(haven)
library(janitor)
library(dplyr)
library(forcats)
library(naniar)
library(tidyr)

# Import data  ------------------------------------------------------------

# This is hardcoded to my dropbox
raw_survey <- haven::read_sav(
  "/Users/joellarwood/Dropbox/Joel PhD/covid_music/raw_wellbeing_survey.sav"
  ) %>% 
  janitor::clean_names()


# Select variables --------------------------------------------------------

variable_keep <- raw_survey %>% 
  select(
  finished, 
  start_date, 
  end_date, 
  recorded_date, 
  gender,
  age,
  enrolment_school,
  student_status, 
  citizenship, 
  ethnic_group,
  living_situation,
  current_circumstance, 
  covid_19_stress_1:covid_19_stress_13,
  coping_strategies_1:coping_strategies_15,
  generalv_wellbeing_1:generalv_wellbeing_6,
  music_info_4:music_info_5
) %>% 
  mutate(
    finished = if_else(
      finished == 1, 
      TRUE, 
      FALSE
    ),
    gender = if_else(
      gender == 1,
      "male",
      if_else(
        gender == 2,
        "female",
        "prefer not to say"
      )
    )
  ) %>% 
  naniar::add_prop_miss() 

# Lots of missing data. I am going to filter when enrolement school is missing as an indication of an unantamped survey 

atempted_survey <- variable_keep %>% 
  tidyr::drop_na(enrolment_school)


# write condensed survey --------------------------------------------------

write_csv(
  atempted_survey,
  "reduced_international_student_survey.csv"
)
  
write_rds(  atempted_survey,
            "reduced_international_student_survey.rds"
)
 


