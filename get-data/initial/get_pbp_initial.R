library(httr)
library(dplyr)
library(tidyr)
library(janitor)
library(euroleagueRscrape)

# all_results <- readRDS("data/initial-extracts/euroleague_match_results.rds")
all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))

all_seasons_pbp <- data.frame()

seasons_to_get <- paste0("E", 2010:2022)

for(each_season in seasons_to_get) {
  
  print(paste0("scraping season: ", each_season))
  
  results_df <- all_results %>% filter(season_code == each_season)
  
  all_pbp <- data.frame()
  
  for(each_game in 1:nrow(results_df)) {
    Sys.sleep(1)
    each_df <- get_each_pbp(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
    all_pbp <- bind_rows(all_pbp, each_df)
  }
  
  all_seasons_pbp <- bind_rows(all_seasons_pbp, all_pbp)
  
}

save_to_rel(df = all_seasons_pbp, file_name = "pbp_from_2010", release_tag = "pbp")
# saveRDS(all_seasons_pbp, "data/initial-extracts/pbp2015_to_2022.rds")


for(each_season in seasons_to_get) {
  print(paste0("saving season: ", each_season))
  
  each_pbp_df <- all_seasons_pbp |> filter(season_code == each_season)
  save_to_rel(df = each_pbp_df, file_name = paste0("pbp_", gsub("E", "", each_season)), release_tag = "pbp")
}
