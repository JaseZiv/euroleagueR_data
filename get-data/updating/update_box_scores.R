library(euroleagueRscrape)
library(dplyr)


source(paste0(here::here(), "/R/helpers.R"))

current_season <- "E2023"

# all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))
all_results <- read_from_rel(file_name = "euroleague_match_results", repo_name = "euroleagueR_data", tag_name = "match_results")

results_df <- all_results |> 
  filter(audience_confirmed == "TRUE") |> 
  filter(season_code == current_season)

#==================================================================================================================================================#
# # this is just for the first games(s) of a new season so that we are able to create a new season's file in the Releases,
# # for subsequent reads of future matches:
# season_team_box_df <- data.frame()
# season_player_box_df <- data.frame()
# 
# for(each_game in 1:nrow(results_df)) {
#   Sys.sleep(1.5)
#   
#   game_list <- get_box_list(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
#   
#   team_box <- get_box_stats(box_list = game_list, team_or_player = "team")
#   team_box <- bind_cols(season_code = results_df$season_code[each_game], code=results_df$code[each_game], team_box)
#   player_box <- get_box_stats(box_list = game_list, team_or_player = "player")
#   player_box <- bind_cols(season_code = results_df$season_code[each_game], code=results_df$code[each_game], player_box)
#   
#   season_team_box_df <- bind_rows(season_team_box_df, team_box)
#   season_player_box_df <- bind_rows(season_player_box_df, player_box)
# }
# 
# save_to_rel(df = season_player_box_df, file_name = paste0("player_box_", gsub("E", "", current_season)), release_tag = "box_scores")
# save_to_rel(df = season_team_box_df, file_name = paste0("team_box_", gsub("E", "", current_season)), release_tag = "box_scores")


#==================================================================================================================================================#



# the below is for when there is already some data for the current season saved:

# existing_team_box <- tryCatch(readRDS(url(paste0("https://github.com/JaseZiv/euroleagueR_data/releases/download/box_scores/team_box_", gsub("E", "", current_season), ".rds"))), error = function(e) data.frame())
existing_team_box <- read_from_rel(file_name = paste0("team_box_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "box_scores")
# existing_player_box <- tryCatch(readRDS(url(paste0("https://github.com/JaseZiv/euroleagueR_data/releases/download/box_scores/player_box_", gsub("E", "", current_season), ".rds"))), error = function(e) data.frame())
existing_player_box <- read_from_rel(file_name = paste0("player_box_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "box_scores")

missing_matches <- results_df |> select(season_code, code) |> 
  anti_join(existing_player_box, by = c("season_code", "code"))


new_team_box_df <- data.frame()
new_player_box_df <- data.frame()

for(each_game in 1:nrow(missing_matches)) {
  Sys.sleep(1.5)
  
  game_list <- tryCatch(get_box_list(gamecode = missing_matches$code[each_game], seasoncode = missing_matches$season_code[each_game]), error = function(e) list())
  
  if(length(game_list) > 0) {
    team_box <- get_box_stats(box_list = game_list, team_or_player = "team")
    team_box <- bind_cols(season_code = missing_matches$season_code[each_game], code=missing_matches$code[each_game], team_box)
    player_box <- get_box_stats(box_list = game_list, team_or_player = "player")
    player_box <- bind_cols(season_code = missing_matches$season_code[each_game], code=missing_matches$code[each_game], player_box)
    
    new_team_box_df <- bind_rows(new_team_box_df, team_box)
    new_player_box_df <- bind_rows(new_player_box_df, player_box)
  } 
}



team_box_all_seasons <- bind_rows(existing_team_box, new_team_box_df)
player_box_all_seasons <- bind_rows(existing_player_box, new_player_box_df)


save_to_rel(df = player_box_all_seasons, file_name = paste0("player_box_", gsub("E", "", current_season)), release_tag = "box_scores")
save_to_rel(df = team_box_all_seasons, file_name = paste0("team_box_", gsub("E", "", current_season)), release_tag = "box_scores")
