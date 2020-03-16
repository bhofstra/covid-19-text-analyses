library(biorrxiv)
library(aRxiv)
library(pdftools)
require(tidyverse)
require(tm)
require(quanteda)

# initiating
yourpath <- "xxx"
yourpathtopdfs <-  "xxx"
update <- "20200316"

#---------------------------------------------------------------------------------------------------------------------------------------
# FIRST BIORXIV

#---------------------------------------------------------------------------------------------------------------------------------------
# DECEMBER

bioarxivdec <- list()
for (i in 15:31) { # December
  Sys.sleep(runif(1, 5, 10))
  bioarxivdec[[i]] <- biorxiv_content(from = paste0("2019-12-", i), to = paste0("2019-12-", i), limit = 200, format = "list")  
}
bioarxivdec[[19]] <- biorxiv_content(from = "2019-12-19", to = "2019-12-19", limit = 250, format = "list")  


# copydec <- bioarxivdec
# bioarxivdec <- copydec
for (i in 15:31) {
  bioarxivdec[[i]] <- data.frame(matrix(unlist(bioarxivdec[[i]]), nrow = length(bioarxivdec[[i]]), byrow = T), stringsAsFactors=FALSE)
}
bioarxivdec <- bind_rows(bioarxivdec, .id = "column_label")


#---------------------------------------------------------------------------------------------------------------------------------------
# JANUARY

bioarxivjan <- list()
for (i in 1:9) { # January 1-9
  Sys.sleep(runif(1, 5, 10))
  bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-0", i), to = paste0("2020-01-0", i), limit = 200, format = "list")  
}

# need to fill in > 200 outside loop, otherwise it breaks due to rate limit??
bioarxivjan[[9]] <- biorxiv_content(from = "2020-01-09", to = "2020-01-09", limit = 250, format = "list")  


for (i in 10:31) { # January 10-26
  Sys.sleep(runif(1, 5, 10))
  bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-", i), to = paste0("2020-01-", i), limit = 200, format = "list")  
}

# need to fill in > 200 outside loop, otherwise it breaks due to rate limit
bioarxivjan[[15]] <- biorxiv_content(from = "2020-01-15", to = "2020-01-15", limit = 250, format = "list")  # these worked
bioarxivjan[[23]] <- biorxiv_content(from = "2020-01-23", to = "2020-01-23", limit = 250, format = "list")  # these worked

bioarxivjan[[27]] <- biorxiv_content(from = "2020-01-27", to = "2020-01-27", limit = 199, format = "list")
bioarxivjan[[28]] <- biorxiv_content(from = "2020-01-28", to = "2020-01-28", limit = 250, format = "list") # worked
bioarxivjan[[29]] <- biorxiv_content(from = "2020-01-29", to = "2020-01-29", limit = 200, format = "list")
bioarxivjan[[30]] <- biorxiv_content(from = "2020-01-30", to = "2020-01-30", limit = 200, format = "list")
bioarxivjan[[31]] <- biorxiv_content(from = "2020-01-31", to = "2020-01-31", limit = 250, format = "list")  # worked

# for (i in 27:31) { # January 27-31
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-", i), to = paste0("2020-01-", i), limit = 200, format = "list")
# }

copyjan <- bioarxivjan
bioarxivjan <- copyjan

for (i in seq(bioarxivjan)) {
  bioarxivjan[[i]] <- data.frame(matrix(unlist(bioarxivjan[[i]]), nrow = length(bioarxivjan[[i]]), byrow = T), stringsAsFactors=FALSE)
}
bioarxivjan <- bind_rows(bioarxivjan, .id = "column_label")


#---------------------------------------------------------------------------------------------------------------------------------------
# FEBRUARY

bioarxivfeb <- list()
for (i in 1:9) { # February
  Sys.sleep(runif(1, 5, 10))
  bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-0", i), to = paste0("2020-02-0", i), limit = 200, format = "list")  
}

for (i in 10:29) { # February
  Sys.sleep(runif(1, 5, 10))
  bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-", i), to = paste0("2020-02-", i), limit = 200, format = "list")  
}

bioarxivfeb[[20]] <- biorxiv_content(from = "2020-02-20", to = "2020-02-20", limit = 250, format = "list")  # worked
bioarxivfeb[[21]] <- biorxiv_content(from = "2020-02-21", to = "2020-02-21", limit = 100, format = "list")  # worked
bioarxivfeb[[22]] <- biorxiv_content(from = "2020-02-22", to = "2020-02-22", limit = 200, format = "list")  # worked
bioarxivfeb[[23]] <- biorxiv_content(from = "2020-02-23", to = "2020-02-23", limit = 200, format = "list")  # worked
bioarxivfeb[[24]] <- biorxiv_content(from = "2020-02-24", to = "2020-02-24", limit = 200, format = "list")  # worked
bioarxivfeb[[25]] <- biorxiv_content(from = "2020-02-25", to = "2020-02-25", limit = 250, format = "list")  # worked
bioarxivfeb[[26]] <- biorxiv_content(from = "2020-02-26", to = "2020-02-26", limit = 200, format = "list")  # worked
bioarxivfeb[[27]] <- biorxiv_content(from = "2020-02-27", to = "2020-02-27", limit = 250, format = "list")  # worked
bioarxivfeb[[28]] <- biorxiv_content(from = "2020-02-28", to = "2020-02-28", limit = 250, format = "list")  # worked
bioarxivfeb[[29]] <- biorxiv_content(from = "2020-02-28", to = "2020-02-28", limit = 250, format = "list")  # worked


# for (i in 21:28) { # February
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-", i), to = paste0("2020-02-", i), limit = 200, format = "list")  
# }

copyfeb <- bioarxivfeb
bioarxivfeb <- copyfeb
for (i in seq(bioarxivfeb)) {
  bioarxivfeb[[i]] <- data.frame(matrix(unlist(bioarxivfeb[[i]]), nrow = length(bioarxivfeb[[i]]), byrow = T), stringsAsFactors=FALSE)
}
bioarxivfeb <- bind_rows(bioarxivfeb, .id = "column_label")


#---------------------------------------------------------------------------------------------------------------------------------------
# March 1-15 -->

bioarxivmarch <- list()
for (i in 1:9) { # December
  Sys.sleep(runif(1, 5, 10))
  bioarxivmarch[[i]] <- biorxiv_content(from = paste0("2020-03-0", i), to = paste0("2020-03-0", i), limit = 200, format = "list")  
}
bioarxivmarch[[5]] <- biorxiv_content(from = "2020-03-05", to = "2020-03-05", limit = 300, format = "list")  # worked

for (i in 10:15) { # December
  Sys.sleep(runif(1, 5, 10))
  bioarxivmarch[[i]] <- biorxiv_content(from = paste0("2020-03-", i), to = paste0("2020-03-", i), limit = 200, format = "list")  
}



for (i in seq(bioarxivmarch)) {
  bioarxivmarch[[i]] <- data.frame(matrix(unlist(bioarxivmarch[[i]]), nrow = length(bioarxivmarch[[i]]), byrow = T), stringsAsFactors=FALSE)
}
bioarxivmarch <- bind_rows(bioarxivmarch, .id = "column_label")


biorxiv <- rbind(bioarxivdec, bioarxivjan, bioarxivfeb, bioarxivmarch)
biorxiv$column_label <- NULL
save(biorxiv, file = paste0(yourpath, "biorxivfull_", update, ".Rda"))


#---------------------------------------------------------------------------------------------------------------------------------------
# APPENDING


biorxiv$X2 <- gsub("uncover", "", tolower(biorxiv$X2))
biorxiv$X10 <- gsub("uncover", "", tolower(biorxiv$X10))

biorxiv$v1 <- ifelse(grepl("2019-ncov", tolower(biorxiv$X2)) | 
                        grepl("covid", tolower(biorxiv$X2)) |
                        grepl("ncov", tolower(biorxiv$X2)) |
                        grepl("corona", tolower(biorxiv$X2)) |
                        grepl("covid-2019", tolower(biorxiv$X2)) |
                        grepl("covid-19", tolower(biorxiv$X2)) |
                        grepl("covid19", tolower(biorxiv$X2)) |
                        grepl("19covid", tolower(biorxiv$X2)) |
                        grepl("19-covid", tolower(biorxiv$X2)) |
                        grepl("2019-covid", tolower(biorxiv$X2)) |
                        grepl("coronavirus", tolower(biorxiv$X2)) |
                       grepl("sars-cov-2", tolower(biorxiv$X2)) |
                       grepl("2019-ncov", tolower(biorxiv$X10)) | 
                       grepl("covid", tolower(biorxiv$X10)) |
                       grepl("ncov", tolower(biorxiv$X10)) |
                       grepl("corona", tolower(biorxiv$X10)) |
                       grepl("covid-2019", tolower(biorxiv$X10)) |
                       grepl("covid-19", tolower(biorxiv$X10)) |
                       grepl("covid19", tolower(biorxiv$X10)) |
                       grepl("19covid", tolower(biorxiv$X10)) |
                       grepl("19-covid", tolower(biorxiv$X10)) |
                       grepl("2019-covid", tolower(biorxiv$X10)) |
                       grepl("coronavirus", tolower(biorxiv$X10)) |
                       grepl("sars-cov-2", tolower(biorxiv$X10))
                       , 1, 0)
biorxivcovid <- biorxiv[biorxiv$v1 == 1,]

require(data.table)
biorxivcovid <- data.table(biorxivcovid)
biorxivcovid <- biorxivcovid[biorxivcovid[, .I[X7 == max(X7)], by=X1]$V1]
save(biorxivcovid, file = paste0(yourpath, "biorxivcovid_", update, ".Rda"))







#---------------------------------------------------------------------------------------------------------------------------------------
# SECOND ARXIV

# aRxiv
covid1 <- arxiv_search(query = "covid-19")
covid2 <- arxiv_search(query = "covid-2019")
covid3 <- arxiv_search(query = "covid19")
covid4 <- arxiv_search(query = "19-covid")

covid5 <- arxiv_search(query = "19-covid")
covid6 <- arxiv_search(query = "2019-covid")
covid7 <- arxiv_search(query = "19covid")
covid8 <- arxiv_search(query = "19-covid")

ncov1 <- arxiv_search(query = "2019-ncov")
ncov2 <- arxiv_search(query = "ncov")


sars <- arxiv_search(query = "sars-cov-2")
corona1 <- arxiv_search(query = '"corona" AND "virus"', limit=1000, ascending = FALSE)
corona2 <- arxiv_search(query = "coronavirus", limit=1000, ascending = FALSE)
corona2 <- corona2[-c(42:45), ] # Papers that are too early

arxivcovid <- rbind(covid1, corona1, corona2, ncov2)
arxivcovid <- data.table(arxivcovid)
arxivcovid <- unique(arxivcovid)
save(arxivcovid, file = paste0(yourpath, "arxivcovid_", update, ".Rda"))


#---------------------------------------------------------------------------------------------------------------------------------------
# SECOND ARXIV

# Download pdfs

for (i in 1:nrow(arxivcovid)) {
  
  download.file(arxivcovid[i, 9],  paste0(yourpathtopdfs, "arxiv", i, "_", arxivcovid[i,6], ".pdf"), mode="wb")
  
}

for (i in 1:nrow(biorxivcovid)) {
  
  download.file(paste0("https://www.biorxiv.org/content/", biorxivcovid[i,1], "v", biorxivcovid[i,7], ".full.pdf"), paste0(yourpathtopdfs, "biorxiv_", i, "_", biorxivcovid[i,4], ".pdf"), mode = "wb")
  
}










