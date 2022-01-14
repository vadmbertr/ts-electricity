library(lubridate)
library(XML)

fromy <- 2015
toy <- 2021
elec.swap.df <- c()
for (y in fromy:toy) {
  destfile <- paste0("data/swap-elec-", y, ".xml")
  if (! file.exists(destfile)) {
    download.file(
      url = paste0("https://eco2mix.rte-france.com/curves/getDonneesMarche?=&dateDeb=01/01/", y, "&dateFin=01/01/", y+1, "&mode=NORM&_=1642058630739"), 
      destfile = destfile)
  }
  data <- xmlParse(destfile)
  swap <- as.integer(sapply(data["//type[@perimetre='FR']/valeur"], as, 
                            "integer"))
  d <- ymd_hms(paste0(y, "-01-01 00:00:00"), tz = "Europe/Paris")
  datetime <- c(d)
  for (i in 1:(length(swap)-1)) {
    datetime <- c(datetime, d + hours(i))
  }
  elec.swap.df <- rbind(elec.swap.df,
                        data.frame(datetime = datetime, swap = swap))
}
save(elec.swap.df, file = "data/swap-elec.Rda")