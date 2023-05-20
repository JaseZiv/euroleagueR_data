library(httr)
library(dplyr)
library(tidyr)
library(euroleagueRscrape)


# all_results <- readRDS("data/initial-extracts/euroleague_match_results.rds")
all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))



all_seasons_shots <- data.frame()

seasons_to_get <- paste0("E", 2015:2022)

for(each_season in seasons_to_get) {
  
  print(paste0("scraping season: ", each_season))
  
  results_df <- all_results %>% filter(season_code == each_season) |> 
    filter(confirmedDate == "TRUE")
  
  all_shots <- data.frame()
  
  for(each_game in 1:nrow(results_df)) {
    Sys.sleep(3)
    each_df <- euroleagueRscrape::get_each_shots(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
    all_shots <- bind_rows(all_shots, each_df)
  }
  
  all_seasons_shots <- bind_rows(all_seasons_shots, all_shots)
  
}


save_to_rel(df = all_seasons_shots, file_name = "shots2015_to_2022", release_tag = "shot_data")
# saveRDS(all_seasons_shots, "data/initial-extracts/shots2015_to_2022.rds")










