# function to read in data from releases:
read_from_rel <- function(file_name, repo_name, tag_name) {
  
  piggyback::pb_download(paste0(file_name, ".rds"),
                         repo = paste0("JaseZiv/", repo_name),
                         tag = tag_name,
                         dest = tempdir())
  
  readRDS(paste0(tempdir(), "/", file_name, ".rds"))
  
}


# function to call to save to GitHub Releases
save_to_rel_csv <- function(df, file_name) {
  
  Sys.setenv(TZ = "Australia/Melbourne")
  
  temp_dir <- tempdir(check = TRUE)
  .f_name <- paste0(file_name,".csv")
  
  write.csv(df, file.path(temp_dir, .f_name), row.names = F)
  
  piggyback::pb_upload(file.path(temp_dir, .f_name),
                       repo = "JaseZiv/euroleagueR_data",
                       tag = "csv_copies"
  )
  
}
