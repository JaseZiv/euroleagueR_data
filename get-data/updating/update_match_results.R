library(dplyr)
library(rlang)
library(euroleagueRscrape)

source(paste0(here::here(), "/R/helpers.R"))

current_season <- "E2023"

# get season rounds data
# all_season_rounds <- readRDS("data/updated-extracts/all_season_rounds.rds")
# all_season_rounds <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/all_season_rounds.rds"))

all_season_rounds <- read_from_rel(file_name = "all_season_rounds", repo_name = "euroleagueR_data", tag_name = "league_meta")

# read in the existing match results data
# existing_results <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/match_results/euroleague_match_results.rds"))
existing_results <- read_from_rel(file_name = "euroleague_match_results", repo_name = "euroleagueR_data", tag_name = "match_results")

# filter down so we only have current season's results, and matches that have been played
current_season_results <- existing_results |> 
  filter(season_code == current_season) |> 
  filter(audience_confirmed == "TRUE")

# now we also want to remove the most recent round played and re-scrape until a new round becomes available
last_round <- max(as.numeric(current_season_results$round_round))
current_season_results <- current_season_results |> 
  filter(round_round != as.character(last_round))


# only get the match rounds for the current season that haven't yet been played
round_scrape_df <- all_season_rounds|> 
  filter(season_code == current_season) |> 
  anti_join(current_season_results |> 
              mutate(round_round = as.numeric(round_round)), 
            by = c("season_code", "phase_type_code", "round" = "round_round"))


#-------------------------------------------------------------------------------
# start scrape
#-------------------------------------------------------------------------------

updated_results <- data.frame()

for(each_round in 1:nrow(round_scrape_df)) {
  Sys.sleep(2)
  
  df <- match_results(seasoncode = current_season, round_phase = round_scrape_df[each_round, "phase_type_code"], round_number = round_scrape_df[each_round, "round"])
  
  # remove any empty columns as these make joining really difficult if they're not removed
  df[sapply(df, rlang::is_empty)] <- NULL
  
  df <- df |> mutate_if(is.list, as.character)
  
  updated_results <- bind_rows(updated_results, df)
}

# add updated results to existing season's data
current_season_results <- current_season_results |> 
  bind_rows(updated_results) |> 
  distinct(season_code, code, .keep_all = T)

# combine all together
existing_results <- existing_results |> 
  filter(season_code != current_season) |> 
  bind_rows(current_season_results)


save_to_rel(df = existing_results, file_name = "euroleague_match_results", release_tag = "match_results")
# saveRDS(existing_results, "data/updated-extracts/euroleague_match_results.rds")

