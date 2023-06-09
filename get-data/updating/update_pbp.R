library(euroleagueRscrape)
library(dplyr)

current_season <- "E2022"

existing_pbp <- readRDS(url(paste0("https://github.com/JaseZiv/euroleagueR_data/releases/download/pbp/pbp_", gsub("E", "", current_season), ".rds")))

all_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))


current_results <- all_results |> 
  filter(audience_confirmed == "TRUE") |> 
  filter(season_code == current_season)


missing_matches <- current_results |> 
  select(season_code, code) |> 
  mutate(season_code = trimws(season_code), 
         code = as.numeric(code)) |> 
  anti_join(existing_pbp |> 
              mutate(season_code = trimws(season_code), 
                     code = as.numeric(code)), 
            by = c("season_code", "code"))


new_pbp_df <- data.frame()

for(each_game in 1:nrow(missing_matches)) {
  Sys.sleep(1.5)
  
  each_df <- get_each_pbp(gamecode = missing_matches$code[each_game], seasoncode = missing_matches$season_code[each_game])
  new_pbp_df <- bind_rows(new_pbp_df, each_df)
}

existing_pbp <- existing_pbp |> 
  bind_rows(new_pbp_df)

save_to_rel(df = existing_pbp, file_name = paste0("pbp_", gsub("E", "", current_season)), release_tag = "pbp")

