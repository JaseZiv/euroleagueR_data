library(euroleagueRscrape)
library(dplyr)

current_season <- "E2022"

existing_pbp <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/pbp/pbp_2013_2022.rds"))

all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))


current_results <- all_results |> 
  filter(audience_confirmed == "TRUE") |> 
  filter(season_code == current_season)


missing_matches <- current_results |> select(season_code, code) |> mutate(season_code = trimws(season_code), code = as.numeric(code)) |> 
  anti_join(existing_pbp |> mutate(season_code = trimws(season_code), match_code = as.numeric(match_code)), by = c("season_code", "code" = "match_code"))




