library(dplyr)
library(tidyr)
library(httr)
library(euroleagueRscrape)

#======================================================================================================
# Functions ---------------------------------------------------------------

scrape_each_team <- function(season_code, team_code) {
  
  res <- httr::GET(url = paste0("https://feeds.incrowdsports.com/provider/euroleague-feeds/v2/competitions/E/seasons/", season_code, "/clubs/", tolower(team_code), "/people"))
  players <- res |> content()
  
  return(players)
  
}


clean_team_df <- function(team_list) {
  
  df <- cbind(team_list) |> 
    data.frame() |> 
    unnest_wider(col = 1) |> 
    unnest_wider(col = c(person, club, season, images), names_sep = ".") |> 
    unnest_wider(col = c(person.country, person.birthCountry), names_sep = "_")
  
  df <- df |> 
    select(
      season.code, club.code, club.name, person.code, person.passportName, person.passportSurname, person.name,
      person.country_name, person.height, person.weight, person.birthDate, person.birthCountry_name, 
      person.twitterAccount, person.instagramAccount, person.facebookAccount, active, startDate, endDate,
      dorsal, positionName, lastTeam, externalId, images.headshot, images.action
    )
  
  return(df)
}


#======================================================================================================
# Setup -------------------------------------------------------------------

source(paste0(here::here(), "/R/helpers.R"))

current_season <- "E2024"

euroleague_clubs <- read_from_rel(file_name = "euroleague_clubs", repo_name = "euroleagueR_data", tag_name = "league_meta")

filt_df <- euroleague_clubs |> 
  filter(season_code == current_season)


#======================================================================================================
# Scrape and Save ---------------------------------------------------------

# let's try looping through each team in the filtered teams data set and parsing the player data...
all_players <- data.frame()

for(each_team in 1:nrow(filt_df)) {
  print(paste0("scraping team: ", filt_df$code[each_team]))
  Sys.sleep(2)
  
  each_teams_list <- scrape_each_team(
    season_code = filt_df$season_code[each_team],
    team_code = filt_df$code[each_team]
  )
  
  zz <- clean_team_df(team_list = each_teams_list)
  
  all_players <- bind_rows(all_players, zz)
  
}

# clean up some of the data types and date columns. This may become a pain point in the future if column types inherently 
# change in the freshly scraped data and might need some work to explicitly convert every column to a specific data type
all_players_clean <- all_players |> 
  mutate_if(is.list, as.character) |> 
  mutate_if(is.logical, as.character) |> 
  mutate(person.birthDate = as.Date(person.birthDate),
         startDate = as.Date(startDate),
         endDate = as.Date(endDate)) |> 
  mutate(externalId = as.character(externalId)) |> 
  mutate(person.code = paste0("P", person.code))


# read in existing, removing the current season, to then append a freshly scraped current season's data
existing <- read_from_rel(file_name = "euroleague_player_bios", repo_name = "euroleagueR_data", tag_name = "csv_copies")

existing <- existing |> 
  filter(season.code != current_season)


out <- bind_rows(
  existing, all_players_clean
)

# writing files to release
euroleagueRscrape::save_to_rel(df=out, file_name="euroleague_player_bios", release_tag = "csv_copies")
save_to_rel_csv(df=out, file_name = "euroleague_player_bios")


# saveRDS(all_players_clean, "euroleague_player_bios.rds")
# write.csv(all_players_clean |> mutate_if(is.list, as.character) |> mutate(person.code = paste0("P", person.code)), "euroleague_player_bios.csv", row.names = F)
# 
# 
# did_this_work <- player_box_2023 |> 
#   mutate(player_id = trimws(player_id)) |> 
#   left_join(
#     all_players |> mutate(person.code = paste0("P", person.code)),
#     by = c("player_id" = "person.code", "season_code" = "season.code", "player_team_abbrv" = "club.code")
#   )


