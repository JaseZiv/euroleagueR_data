library(httr)
library(dplyr)
library(tidyr)
library(purrr)
library(jsonlite)
library(euroleagueRscrape)


# seasons_df <- readRDS("data/initial-extracts/euroleague_seasons.rds")
seasons_df <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/euroleague_seasons.rds"))
seasons <- seasons_df$code %>% unlist() %>% sort()

# Rounds ------------------------------------------------------------------

all_season_rounds <-  seasons %>% 
  purrr::map_df(get_season_rounds)

all_season_rounds <- all_season_rounds %>% 
  arrange(season_code, min_game_start_date, round)

# all_season_rounds <- janitor::clean_names(all_season_rounds)

save_to_rel(df = all_season_rounds, file_name = "all_season_rounds", release_tag = "league_meta")
# saveRDS(all_season_rounds, "data/initial-extracts/all_season_rounds.rds")

