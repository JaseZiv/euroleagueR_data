library(httr)
library(dplyr)
library(tidyr)
library(purrr)
library(jsonlite)
library(euroleagueRscrape)

res <- httr::GET(url = "https://feeds.incrowdsports.com/provider/euroleague-feeds/v2/competitions/E/seasons") |>
  httr::content()

seasons_df <- res$data |> jsonlite::toJSON() |> jsonlite::fromJSON()|> data.frame()

seasons_df <- seasons_df|> tidyr::unnest(winner, names_sep = "_")
seasons_df <- janitor::clean_names(seasons_df)

save_to_rel(df = seasons_df, file_name = "euroleague_seasons", release_tag = "league_meta")
# saveRDS(seasons_df, "data/initial-extracts/euroleague_seasons.rds")