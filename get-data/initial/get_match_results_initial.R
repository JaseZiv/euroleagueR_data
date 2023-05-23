library(httr)
library(dplyr)
library(tidyr)
library(euroleagueRscrape)


# all_season_rounds <- readRDS("data/initial-extracts/all_season_rounds.rds")
all_season_rounds <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/all_season_rounds.rds"))
seasons <- all_season_rounds$seasonCode %>% unique() %>% sort()

# Results -----------------------------------------------------------------

all_results <- data.frame()

for(each_season in 1:length(seasons)) {
  
  print(paste0("scraping season: ", seasons[each_season]))
  
  round_scrape_df <- all_season_rounds %>% filter(seasonCode == seasons[each_season])
  
  each_season_df <- data.frame()
  
  for(each_round in 1:nrow(round_scrape_df)) {
    Sys.sleep(2)
    
    df <- match_results(seasoncode = seasons[each_season], round_phase = round_scrape_df[each_round, "phaseTypeCode"], round_number = round_scrape_df[each_round, "round"])
    
    # remove any empty columns as these make joining really difficult if they're not removed
    df[sapply(df, is_empty)] <- NULL
    
    df <- df %>% mutate_if(is.list, as.character)
    
    each_season_df <- bind_rows(each_season_df, df)
  }
  
  all_results <- bind_rows(all_results, each_season_df)
  
}

save_to_rel(df = all_results, file_name = "euroleague_match_results", release_tag = "match_results")
saveRDS(all_results, "data/initial-extracts/euroleague_match_results.rds")

