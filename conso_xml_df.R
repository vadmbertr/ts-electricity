library(lubridate)
library(XML)

fromy <- 2015
toy <- 2021
elec.conso.df <- c()
for (y in fromy:toy) {
  destfile <- paste0("data/conso-elec-", y, ".xml")
  if (! file.exists(destfile)) {
    xmldoc <- newXMLDoc()
    root <- newXMLNode("root", doc = xmldoc)
    starty <- date(paste0(y, "-01-01"))
    endy <- date(paste0(y, "-12-31"))
    ndays <- as.integer(endy - starty) # not a constant because of leap years
    startp <- NULL
    endp <- NULL
    for (i in 0:as.integer(ndays/28)) { # 28: max period for hourly download
      startp <- starty + days(i*28)
      endp <- min(endy, startp + days(27))
      download.file(
        url = paste0("https://eco2mix.rte-france.com/curves/eco2mixWeb?type=conso&dateDeb=",
                     format(startp, "%d-%m-%Y"), "&dateFin=", 
                     format(endp, "%d-%m-%Y"), "&mode=NORM&_=1642264226591"), 
        destfile = destfile)
      data <- xmlParse(destfile)
      conso <- as.integer(sapply(data["//type[@v='Consommation']/valeur"], as, 
                                 "integer"))
      overflowfactor <- length(conso) / (as.integer(endp - startp)+1) / 24
      if (overflowfactor > 1) {
        conso <- conso[c(T, rep(F, overflowfactor-1))]
      }
      elec.conso.df <- rbind(elec.conso.df,
                             data.frame(datetime = startp + hours(0:(length(conso)-1)),
                                        conso = conso))
    }
  }
}
save(elec.conso.df, file = "data/conso-elec.Rda")
