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
# all_shots <- data.frame()
# 
# for(each_game in 1:nrow(results_df)) {
#   Sys.sleep(1)
#   each_df <- euroleagueRscrape::get_each_shots(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
#   all_shots <- bind_rows(all_shots, each_df)
# }
# 
# save_to_rel(df = all_shots, file_name = paste0("shots_", gsub("E", "", current_season)), release_tag = "shot_data")
# 
#==================================================================================================================================================#


# existing_shots <- readRDS(url(paste0("https://github.com/JaseZiv/euroleagueR_data/releases/download/shot_data/shots_", gsub("E", "", current_season), ".rds")))
existing_shots <- read_from_rel(file_name = paste0("shots_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "shot_data")



missing_matches <- results_df |> 
  select(season_code, code) |> 
  mutate(season_code = trimws(season_code), 
         code = as.numeric(code)) |> 
  anti_join(existing_shots |> 
              mutate(season_code = trimws(season_code), 
                     code = as.numeric(code)), 
            by = c("season_code", "code"))


new_shots_df <- data.frame()

for(each_game in 1:nrow(missing_matches)) {
  Sys.sleep(1.5)
  
  each_df <- get_each_shots(gamecode = missing_matches$code[each_game], seasoncode = missing_matches$season_code[each_game])
  new_shots_df <- bind_rows(new_shots_df, each_df)
}

new_shots_df <- new_shots_df |> 
  mutate(code = as.character(code))

existing_shots <- existing_shots |> 
  bind_rows(new_shots_df)

save_to_rel(df = existing_shots, file_name = paste0("shots_", gsub("E", "", current_season)), release_tag = "shot_data")
