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
# all_pbp <- data.frame()
# 
# for(each_game in 1:nrow(results_df)) {
#   Sys.sleep(1)
#   each_df <- get_each_pbp(gamecode = results_df$code[each_game], seasoncode = results_df$season_code[each_game])
#   all_pbp <- bind_rows(all_pbp, each_df)
# }
# 
# save_to_rel(df = all_pbp, file_name = paste0("pbp_", gsub("E", "", current_season)), release_tag = "pbp")
# 
#==================================================================================================================================================#


# existing_pbp <- readRDS(url(paste0("https://github.com/JaseZiv/euroleagueR_data/releases/download/pbp/pbp_", gsub("E", "", current_season), ".rds")))
existing_pbp <- read_from_rel(file_name = paste0("pbp_", gsub("E", "", current_season)), repo_name = "euroleagueR_data", tag_name = "pbp")



missing_matches <- results_df |> 
  select(season_code, code) |> 
  mutate(season_code = trimws(season_code), 
         code = as.numeric(code)) |> 
  anti_join(existing_pbp |> 
              mutate(season_code = trimws(season_code), 
                     code = as.numeric(code)), 
            by = c("season_code", "code"))


new_pbp_df <- data.frame()

if(nrow(missing_matches) > 0) {
  
  for(each_game in 1:nrow(missing_matches)) {
    Sys.sleep(1.5)
    
    each_df <- get_each_pbp(gamecode = missing_matches$code[each_game], seasoncode = missing_matches$season_code[each_game])
    each_df$code <- as.character(each_df$code)
    new_pbp_df <- bind_rows(new_pbp_df, each_df)
    new_pbp_df <- new_pbp_df |> 
      mutate(code = as.character(code))
  }
  
}


existing_pbp <- existing_pbp |> 
  bind_rows(new_pbp_df)

save_to_rel(df = existing_pbp, file_name = paste0("pbp_", gsub("E", "", current_season)), release_tag = "pbp")

