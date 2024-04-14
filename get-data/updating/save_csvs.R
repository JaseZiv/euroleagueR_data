# library(euroleagueRscrape)
library(dplyr)


source(paste0(here::here(), "/R/helpers.R"))

current_season <- "E2023"



# Match Results -----------------------------------------------------------

# all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))
all_results <- read_from_rel(file_name = "euroleague_match_results", repo_name = "euroleagueR_data", tag_name = "match_results")

save_to_rel_csv(all_results, "euroleague_match_results")

rm(all_results);gc()


# Player Box --------------------------------------------------------------

player_box_historical <- read_from_rel(file_name = "player_box", repo_name = "euroleagueR_data", tag_name = "box_scores")
player_box_current <- read_from_rel(file_name = paste0("player_box_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "box_scores")

all_player <- bind_rows(
  player_box_historical,
  player_box_current
)

save_to_rel_csv(all_player, "player_box")

rm(player_box_current, player_box_historical, all_player);gc()

# Team Box ----------------------------------------------------------------

team_box_historical <- read_from_rel(file_name = "team_box", repo_name = "euroleagueR_data", tag_name = "box_scores")
team_box_current <- read_from_rel(file_name = paste0("team_box_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "box_scores")

all_team <- bind_rows(
  team_box_historical,
  team_box_current
)

save_to_rel_csv(all_team, "team_box")

rm(team_box_current, team_box_historical, all_team);gc()

