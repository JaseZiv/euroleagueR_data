library(euroleagueRscrape)
library(dplyr)

current_season <- "E2022"

existing_team_box <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/box_scores/team_box.rds"))
existing_player_box <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/box_scores/player_box.rds"))

all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))


current_results <- all_results |> 
  filter(audience_confirmed == "TRUE") |> 
  filter(season_code == current_season)


missing_matches <- current_results |> select(season_code, code) |> 
  anti_join(existing_player_box, by = c("season_code" = "season", "code"))


new_team_box_df <- data.frame()
new_player_box_df <- data.frame()

for(each_game in 1:nrow(missing_matches)) {
  Sys.sleep(1.5)
  
  game_list <- get_box_list(gamecode = missing_matches$code[each_game], seasoncode = missing_matches$season_code[each_game])
  
  team_box <- get_box_stats(box_list = game_list, team_or_player = "team")
  team_box <- bind_cols(season = missing_matches$season_code[each_game], code=missing_matches$code[each_game], team_box)
  player_box <- get_box_stats(box_list = game_list, team_or_player = "player")
  player_box <- bind_cols(season = missing_matches$season_code[each_game], code=missing_matches$code[each_game], player_box)
  
  new_team_box_df <- bind_rows(new_team_box_df, team_box)
  new_player_box_df <- bind_rows(new_player_box_df, player_box)
}



team_box_all_seasons <- bind_rows(existing_team_box, new_team_box_df)
player_box_all_seasons <- bind_rows(existing_player_box, new_player_box_df)


save_to_rel(df = player_box_all_seasons, file_name = "player_box", release_tag = "box_scores")
save_to_rel(df = team_box_all_seasons, file_name = "team_box", release_tag = "box_scores")
