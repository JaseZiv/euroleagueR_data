library(httr)
library(dplyr)
library(janitor)
library(euroleagueRscrape)

# seasons_df <- readRDS("data/initial-extracts/euroleague_seasons.rds")
seasons_df <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/euroleague_seasons.rds"))

current_season <- "E2022"

# existing_season_rounds <- readRDS("data/initial-extracts/all_season_rounds.rds")
existing_season_rounds <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/all_season_rounds.rds"))


current_season_rounds <-  get_season_rounds(season_code = current_season)

current_season_rounds <- current_season_rounds %>% 
  arrange(season_code, min_game_start_date, round)

existing_season_rounds <- existing_season_rounds |> 
  filter(season_code != current_season) |> 
  dplyr::bind_rows(current_season_rounds)



save_to_rel(df = existing_season_rounds, file_name = "all_season_rounds", release_tag = "league_meta")
# saveRDS(existing_season_rounds, "data/updated-extracts/all_season_rounds.rds")



