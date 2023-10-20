library(httr)
library(dplyr)
library(tidyr)
library(purrr)
library(jsonlite)


get_clubs <- function(season_code) {
  res_clubs <- httr::GET(url = paste0("https://feeds.incrowdsports.com/provider/euroleague-feeds/v2/competitions/E/seasons/", season_code, "/clubs")) %>% 
    content()
  
  clubs <- res_clubs$data %>% 
    jsonlite::toJSON() %>% jsonlite::fromJSON() %>% data.frame()
  
  clubLogo <- clubs$images$crest %>% unlist()
  
  clubs <- clubs %>% 
    dplyr::select(code, name, abbreviatedName, tvCode, editorialName, sponsor,
                  clubPermanentName, clubPermanentAlias, country) %>% 
    tidyr::unnest(country, names_sep = "_")
  
  clubs$seasonCode <- season_code
  clubs$clubLogo <- clubLogo
  
  clubs <- clubs %>% 
    dplyr::select(seasonCode, dplyr::everything())
  
  return(clubs)
  
}


# seasons_df <- readRDS(seasons_df, "data/initial-extracts/euroleague_seasons.rds")
seasons_df <- readRDS(url("https://github.com/JaseZiv/euroleagueR_data/releases/download/league_meta/euroleague_seasons.rds"))
seasons <- seasons_df$code %>% unlist() %>% sort()

all_clubs <- data.frame()

for(i in seasons) {
  Sys.sleep(3)
  print(paste0("scraping season: ", i))
  df <- get_clubs(season_code = i)
  all_clubs <- dplyr::bind_rows(all_clubs, df)
}

all_clubs <- janitor::clean_names(all_clubs)

euroleagueRscrape::save_to_rel(df = all_clubs, file_name = "euroleague_clubs", release_tag = "league_meta")
# saveRDS(all_clubs, "data/initial-extracts/euroleague_clubs.rds")
