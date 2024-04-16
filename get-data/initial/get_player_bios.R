library(dplyr)
library(httr)
library(tidyr)
library(euroleagueRscrape)

# headers = c(
#   `accept` = "application/json, text/plain, */*",
#   `accept-language` = "en-AU,en-GB;q=0.9,en-US;q=0.8,en;q=0.7",
#   `origin` = "https://www.euroleaguebasketball.net",
#   `referer` = "https://www.euroleaguebasketball.net/",
#   `sec-ch-ua` = '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
#   `sec-ch-ua-mobile` = "?0",
#   `sec-ch-ua-platform` = '"macOS"',
#   `sec-fetch-dest` = "empty",
#   `sec-fetch-mode` = "cors",
#   `sec-fetch-site` = "cross-site",
#   `user-agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
# )


scrape_each_team <- function(season_code, team_code) {
  
  res <- httr::GET(url = paste0("https://feeds.incrowdsports.com/provider/euroleague-feeds/v2/competitions/E/seasons/", season_code, "/clubs/", tolower(team_code), "/people"))
  players <- res |> content()
  
  return(players)
  
}


clean_team_df <- function(team_list) {
  
  df <- cbind(team_list) |> 
    data.frame() |> 
    unnest_wider(col = 1) |> 
    unnest_wider(col = c(person, club, season, images), names_sep = ".") |> 
    unnest_wider(col = c(person.country, person.birthCountry), names_sep = "_")
  
  df <- df |> 
    select(
      season.code, club.code, club.name, person.code, person.passportName, person.passportSurname, person.name,
      person.country_name, person.height, person.weight, person.birthDate, person.birthCountry_name, 
      person.twitterAccount, person.instagramAccount, person.facebookAccount, active, startDate, endDate,
      dorsal, positionName, lastTeam, externalId, images.headshot, images.action
    )
  
  return(df)
}



filt_df <- euroleague_clubs |> 
  filter(season_code >= "E2019")


# let's try looping through each team in the filtered teams data set and parsing the player data...
all_players <- data.frame()

for(each_team in 1:nrow(filt_df)) {
  print(paste0("scraping team: ", filt_df$code[each_team]))
  Sys.sleep(2)
  
  each_teams_list <- scrape_each_team(
    season_code = filt_df$season_code[each_team],
    team_code = filt_df$code[each_team]
  )
  
  zz <- clean_team_df(team_list = each_teams_list)
  
  all_players <- bind_rows(all_players, zz)
  
}


all_players_clean <- all_players |> 
  mutate_if(is.list, as.character) |> 
  mutate(person.birthDate = as.Date(person.birthDate),
         startDate = as.Date(startDate),
         endDate = as.Date(endDate)) |> 
  mutate(person.code = paste0("P", person.code))


# writing files to release
euroleagueRscrape::save_to_rel(df=all_players_clean, file_name="euroleague_player_bios", release_tag = "csv_copies")
save_to_rel_csv(df=all_players_clean, file_name = "euroleague_player_bios")
