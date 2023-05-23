library(httr)
library(dplyr)
library(tidyr)
library(euroleagueRscrape)


# all_results <- readRDS("data/initial-extracts/euroleague_match_results.rds")
all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))



all_seasons_shots <- data.frame()

seasons_to_get <- paste0("E", 2010:2022)

for(each_season in seasons_to_get) {
  
  print(paste0("scraping season: ", each_season))
  
  results_df <- all_results %>% filter(season_code == each_season) |> 
    filter(confirmed_date == "TRUE")
  
  all_shots <- data.frame()
  
  for(each_game in 1:nrow(results_df)) {
    Sys.sleep(1)
    each_df <- euroleagueRscrape::get_each_shots(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
    all_shots <- bind_rows(all_shots, each_df)
  }
  
  all_seasons_shots <- bind_rows(all_seasons_shots, all_shots)
  
}


save_to_rel(df = all_seasons_shots, file_name = "shots_from_2010", release_tag = "shot_data")
# saveRDS(all_seasons_shots, "data/initial-extracts/shots2010_to_2022.rds")


for(each_season in seasons_to_get) {
  print(paste0("saving season: ", each_season))
  
  each_shot_df <- all_seasons_shots |> filter(season_code == each_season)
  save_to_rel(df = each_shot_df, file_name = paste0("shots_", gsub("E", "", each_season)), release_tag = "shot_data")
}





