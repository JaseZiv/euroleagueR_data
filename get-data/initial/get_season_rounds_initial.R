library(httr)
library(dplyr)
library(tidyr)
library(purrr)
library(jsonlite)


# seasons_df <- readRDS(seasons_df, "data/initial-extracts/euroleague_seasons.rds")
seasons_df <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/euroleague_seasons.rds"))
seasons <- seasons_df$code %>% unlist() %>% sort()

# Rounds ------------------------------------------------------------------


get_season_rounds <- function(season_code) {
  
  print(paste0("scraping season: ", season_code))
  Sys.sleep(5)
  
  res_rounds <- httr::GET(url = paste0("https://feeds.incrowdsports.com/provider/euroleague-feeds/v2/competitions/E/seasons/", season_code, "/rounds")) %>% 
    content()
  
  rounds <- res_rounds$data %>% bind_rows()
  rounds <- rounds %>% arrange(minGameStartDate)
  
  return(rounds)
  
}


all_season_rounds <-  seasons %>% 
  purrr::map_df(get_season_rounds)

all_season_rounds <- all_season_rounds %>% 
  arrange(seasonCode, minGameStartDate, round)

save_to_rel(df = all_season_rounds, file_name = "all_season_rounds", release_tag = "league_meta")
# saveRDS(all_season_rounds, "data/initial-extracts/all_season_rounds.rds")

