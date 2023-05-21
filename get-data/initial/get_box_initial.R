
library(dplyr)
library(euroleagueRscrape)


all_results <- readRDS("data/initial-extracts/euroleague_match_results.rds")

team_box_all_seasons <- data.frame()
player_box_all_seasons <- data.frame()


seasons_to_get <- paste0("E", c(2010:2022))

for(each_season in seasons_to_get) {
  
  print(paste0("scraping season: ", each_season))
  
  results_df <- all_results %>% filter(season_code == each_season) |> 
    filter(confirmedDate == "TRUE")
  
  season_team_box_df <- data.frame()
  season_player_box_df <- data.frame()
  
  for(each_game in 1:nrow(results_df)) {
    Sys.sleep(1.5)
    
    game_list <- get_box_list(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
    
    team_box <- get_box_stats(box_list = game_list, team_or_player = "team")
    team_box <- bind_cols(season = results_df$season_code[each_game], code=results_df$code[each_game], team_box)
    player_box <- get_box_stats(box_list = game_list, team_or_player = "player")
    player_box <- bind_cols(season = results_df$season_code[each_game], code=results_df$code[each_game], player_box)
    
    season_team_box_df <- bind_rows(season_team_box_df, team_box)
    season_player_box_df <- bind_rows(season_player_box_df, player_box)
  }
  
  team_box_all_seasons <- bind_rows(team_box_all_seasons, season_team_box_df)
  player_box_all_seasons <- bind_rows(player_box_all_seasons, season_player_box_df)
  
}



save_to_rel(df = player_box_all_seasons, file_name = "player_box_2010_to_2022", release_tag = "box_scores")
save_to_rel(df = team_box_all_seasons, file_name = "team_box_2010_to_2022", release_tag = "box_scores")

# saveRDS(team_box_all_seasons, "data/initial-extracts/team_box_all_seasons_2022.rds")
# saveRDS(player_box_all_seasons, "data/initial-extracts/player_box_all_seasons_2022.rds")



