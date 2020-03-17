#############################################
# Author:   Bas Hofstra                     #
# Dates:    17-03-2020                      #
#############################################

# Required packages thus far
rm(list = ls()) 
library(biorrxiv)
library(aRxiv)
library(pdftools)
require(tidyverse)
require(tm)
require(quanteda)
require(httr)
require(xml2)
require(rvest)
require(ggplot2)

# initiating
yourpath <- "xx"
yourpathtopdfs <-  "xx"
update <- "20200317"

#------------------------------------------------------------------------------------------
# FIRST MEDRXIV AND BIORXIV (TOGETHER IN CURATED LIST ONLINE)
#------------------------------------------------------------------------------------------
# GOALS:
# 1 From the curated list obtain links
# 2 From those links download websites
# 3 From those websites get pdf urls
# 4 From those website extract metadata
# 5 Download pdfs
# 6 Get arxiv papers as well

#------------------------------------------------------------------------------------------
# 1 From the curated list obtain links
#------------------------------------------------------------------------------------------

# first get the links of the papers?
# second to nth page
urllist <- list()
doclist <- list()
urls <- list()
for (i in 2:54) {
  
  urllist[[i]] <- paste0("https://connect.medrxiv.org/relate/content/181?page=", i)
  
  doclist[[i]] <- read_html(urllist[[i]])
  
  urls[[i]] <- html_attr(html_nodes(doclist[[i]], "a"), "href")
  #urls[[i]] <- urls[[i]][c(7:26), ]
  #urls[[i]] <-  as.character(urls[[i]])
  
}

vector <- unlist(urls)
vector <- unique(vector)
pap <- bind_rows(urls, .id = "column_label")

# and the first first page
url <- "https://connect.medrxiv.org/relate/content/181"
doc <- read_html(url)
doc <- html_attr(html_nodes(doc, "a"), "href")
doc <- unique(doc[7:26])

# combine first and later pages
# so these are all the links!
paper <- c(doc, vector)
           
      
#------------------------------------------------------------------------------------------
# 2 From those links download websites
#------------------------------------------------------------------------------------------

# get htmls
doclist <- list()
for (i in 1:539) {
  
  Sys.sleep(runif(1, 1, 3))
  doclist[[i]] <- read_html(paper[i])
  
}

#------------------------------------------------------------------------------------------
# 3 From those websites get pdf urls
#------------------------------------------------------------------------------------------

# find pdf urls in the xml files?
pdfurl <- list()
for (i in 1:539) {
 
  pdfurl[[i]] <- as.data.frame(as.character(html_attr(html_nodes(doclist[[i]], "a"), "href")))
  pdfurl[[i]] <- as.character(pdfurl[[i]][grepl("full.pdf", pdfurl[[i]][,1]), ])
  pdfurl[[i]] <- gsub("\\+html", "", pdfurl[[i]])
  pdfurl[[i]] <- unique(pdfurl[[i]])
  pdfurl[[i]] <- paste0("https://www.medrxiv.org", pdfurl[[i]])
 
}

#------------------------------------------------------------------------------------------
# 4 From those website extract metadata
#------------------------------------------------------------------------------------------

# LOOP THROUGH THE XMLS AND FIND METADATA FROM THE WEBSITE
# (can be improved significantly)
# (by looking at the dev in the website)
# (for pointers as to what to extract)
# (will improve as we move forward)

metatitles <- list()
metaabstract <- list()
metadoi <- list()
firstnames <- list()
lastnames <- list()
for (i in 1:539) {

  metatitles[[i]] <- doclist[[i]] %>% # title
                         rvest::html_nodes('body') %>%
                         xml2::xml_find_all("//h1[contains(@class, 'highwire-cite-title')]") %>%
                         rvest::html_text()

  
  metaabstract[[i]] <- doclist[[i]] %>% # abstract
                        rvest::html_nodes('body') %>%
                        xml2::xml_find_all("//div[contains(@class, 'section abstract')]") %>%
                        rvest::html_text()
  
  metadoi[[i]] <- doclist[[i]] %>% # doi
                        rvest::html_nodes('body') %>%
                        xml2::xml_find_all("//span[contains(@class, 'highwire-cite-metadata-doi')]") %>%
                        rvest::html_text()

  firstnames[[i]] <- doclist[[i]] %>% # given names of all authors
                        rvest::html_nodes('body') %>%
                        xml2::xml_find_all("//span[contains(@class, 'nlm-given-names')]") %>%
                        rvest::html_text()
  firstnames[[i]] <- paste(firstnames[[i]], collapse = ";")
  

  lastnames[[i]] <- doclist[[i]] %>% # surnames of all authors
                        rvest::html_nodes('body') %>%
                        xml2::xml_find_all("//span[contains(@class, 'nlm-surname')]") %>%
                        rvest::html_text()
  lastnames[[i]] <- paste(lastnames[[i]], collapse = ";")
  
}

# build dataset am lazy can do way more efficient but this works for now
huh <- as.data.frame(cbind(as.data.frame(unlist(metatitles)), as.data.frame(unlist(metaabstract)), 
                           as.data.frame(unique(unlist(metadoi))), as.data.frame(unlist(firstnames)), 
                           as.data.frame(unlist(lastnames)), as.data.frame(unlist(pdfurl))))
names(huh) <- c("title", "abstract", "doi", "authorfirstnames", "authorlastnames", "pdfurl") # with logical names

# I trippled the authornames with the xml parse, so collapse on uniques.
huh$authorlastnames <- sapply(strsplit(as.character(huh$authorlastnames), ";", fixed = TRUE), function(x) 
                        paste(unique(x), collapse = ";"))

# Nice thing is that I have first and last names separated
# can we infer some things from these authors?
huh$authorfirstnames <- sapply(strsplit(as.character(huh$authorfirstnames), ";", fixed = TRUE), function(x) 
                        paste(unique(x), collapse = ";"))



# save metadata
save(huh, file = paste0(yourpath, "medrxivcovid_", update, ".Rda"))



#------------------------------------------------------------------------------------------
# 5 Download pdfs
#------------------------------------------------------------------------------------------

# so here a loop to downlaod pdfs
huh$pdfurl <- as.character(huh$pdfurl)

for (i in 288:nrow(huh)) {
  
  Sys.sleep(runif(1, 1, 5))
  
  if (http_error(huh[i,6])) { # if there is an error, then its biorxiv
    download.file(gsub("medrxiv", "biorxiv", huh[i, 6]), # so gsub medrxiv to biorxiv in order to get the good link!
                  paste0(yourpathtopdfs, "biorxiv_", i, "_", trimws(sub('.*\\/', '', huh[i,3]), "right"), ".pdf"), mode = "wb")
    }
  else { # no error means it's medrxiv!
    download.file(huh[i, 6], # so just the link we've extracted
                  paste0(yourpathtopdfs, "medrxiv_", i, "_", trimws(sub('.*\\/', '', huh[i,3]), "right"), ".pdf"), mode = "wb")
    }
  
}


#------------------------------------------------------------------------------------------
# xxx tiny viz
#------------------------------------------------------------------------------------------

# get posting date
huh$date <- trimws(sub('.*\\/', '', huh$doi), "right")
huh$date <- sub(".[^.]+$", "",  huh$date)
huh$date <- gsub("\\.", "", huh$date)

tab <- data.frame(table(huh$date))


f1 <- ggplot(tab, aes(x=Var1, y = cumsum(Freq))) + 
  xlab("Date") + ylab("Cumulative research papers on Covid-19") + 
  geom_line(group = 1) +
  theme_bw() + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, size = 4),
        axis.text.y = element_text(size = 6),
        axis.title = element_text(size = 8)) 

ggsave("f1.pdf", plot = f1, device = "pdf", path = "xx",
       scale = 1, width = 14, height = 7, units = c("cm"),
       dpi = "retina")


#---------------------------------------------------------------------------------------------------------------------------------------
# 6 Get arxiv papers as well
#---------------------------------------------------------------------------------------------------------------------------------------

# ARXIV PAPERS?

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

# Download pdfs from arXiv

#arXiv
# Need to remove http first, hence the gsub
for (i in 1:nrow(arxivcovid)) {
  
  download.file(gsub("http://", "", arxivcovid[i, 9]),  paste0(yourpathtopdfs, "arxiv", i, "_", arxivcovid[i,1], ".pdf"), mode="wb")
  
}


# #---------------------------------------------------------------------------------------------------------------------------------------
# # FIRST BIORXIV
# # First part has been blocked out as it has become obsolete
#
# #---------------------------------------------------------------------------------------------------------------------------------------
# # DECEMBER
# 
# bioarxivdec <- list()
# for (i in 15:31) { # December
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivdec[[i]] <- biorxiv_content(from = paste0("2019-12-", i), to = paste0("2019-12-", i), limit = 200, format = "list")  
# }
# bioarxivdec[[19]] <- biorxiv_content(from = "2019-12-19", to = "2019-12-19", limit = 250, format = "list")  
# 
# 
# # copydec <- bioarxivdec
# # bioarxivdec <- copydec
# for (i in 15:31) {
#   bioarxivdec[[i]] <- data.frame(matrix(unlist(bioarxivdec[[i]]), nrow = length(bioarxivdec[[i]]), byrow = T), stringsAsFactors=FALSE)
# }
# bioarxivdec <- bind_rows(bioarxivdec, .id = "column_label")
# 
# 
# #---------------------------------------------------------------------------------------------------------------------------------------
# # JANUARY
# 
# bioarxivjan <- list()
# for (i in 1:9) { # January 1-9
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-0", i), to = paste0("2020-01-0", i), limit = 200, format = "list")  
# }
# 
# # need to fill in > 200 outside loop, otherwise it breaks due to rate limit??
# bioarxivjan[[9]] <- biorxiv_content(from = "2020-01-09", to = "2020-01-09", limit = 250, format = "list")  
# 
# 
# for (i in 10:31) { # January 10-26
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-", i), to = paste0("2020-01-", i), limit = 200, format = "list")  
# }
# 
# # need to fill in > 200 outside loop, otherwise it breaks due to rate limit
# bioarxivjan[[15]] <- biorxiv_content(from = "2020-01-15", to = "2020-01-15", limit = 250, format = "list")  # these worked
# bioarxivjan[[23]] <- biorxiv_content(from = "2020-01-23", to = "2020-01-23", limit = 250, format = "list")  # these worked
# 
# bioarxivjan[[27]] <- biorxiv_content(from = "2020-01-27", to = "2020-01-27", limit = 199, format = "list")
# bioarxivjan[[28]] <- biorxiv_content(from = "2020-01-28", to = "2020-01-28", limit = 250, format = "list") # worked
# bioarxivjan[[29]] <- biorxiv_content(from = "2020-01-29", to = "2020-01-29", limit = 200, format = "list")
# bioarxivjan[[30]] <- biorxiv_content(from = "2020-01-30", to = "2020-01-30", limit = 200, format = "list")
# bioarxivjan[[31]] <- biorxiv_content(from = "2020-01-31", to = "2020-01-31", limit = 250, format = "list")  # worked
# 
# # for (i in 27:31) { # January 27-31
# #   Sys.sleep(runif(1, 5, 10))
# #   bioarxivjan[[i]] <- biorxiv_content(from = paste0("2020-01-", i), to = paste0("2020-01-", i), limit = 200, format = "list")
# # }
# 
# copyjan <- bioarxivjan
# bioarxivjan <- copyjan
# 
# for (i in seq(bioarxivjan)) {
#   bioarxivjan[[i]] <- data.frame(matrix(unlist(bioarxivjan[[i]]), nrow = length(bioarxivjan[[i]]), byrow = T), stringsAsFactors=FALSE)
# }
# bioarxivjan <- bind_rows(bioarxivjan, .id = "column_label")
# 
# 
# #---------------------------------------------------------------------------------------------------------------------------------------
# # FEBRUARY
# 
# bioarxivfeb <- list()
# for (i in 1:9) { # February
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-0", i), to = paste0("2020-02-0", i), limit = 200, format = "list")  
# }
# 
# for (i in 10:29) { # February
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-", i), to = paste0("2020-02-", i), limit = 200, format = "list")  
# }
# 
# bioarxivfeb[[20]] <- biorxiv_content(from = "2020-02-20", to = "2020-02-20", limit = 250, format = "list")  # worked
# bioarxivfeb[[21]] <- biorxiv_content(from = "2020-02-21", to = "2020-02-21", limit = 100, format = "list")  # worked
# bioarxivfeb[[22]] <- biorxiv_content(from = "2020-02-22", to = "2020-02-22", limit = 200, format = "list")  # worked
# bioarxivfeb[[23]] <- biorxiv_content(from = "2020-02-23", to = "2020-02-23", limit = 200, format = "list")  # worked
# bioarxivfeb[[24]] <- biorxiv_content(from = "2020-02-24", to = "2020-02-24", limit = 200, format = "list")  # worked
# bioarxivfeb[[25]] <- biorxiv_content(from = "2020-02-25", to = "2020-02-25", limit = 250, format = "list")  # worked
# bioarxivfeb[[26]] <- biorxiv_content(from = "2020-02-26", to = "2020-02-26", limit = 200, format = "list")  # worked
# bioarxivfeb[[27]] <- biorxiv_content(from = "2020-02-27", to = "2020-02-27", limit = 250, format = "list")  # worked
# bioarxivfeb[[28]] <- biorxiv_content(from = "2020-02-28", to = "2020-02-28", limit = 250, format = "list")  # worked
# bioarxivfeb[[29]] <- biorxiv_content(from = "2020-02-28", to = "2020-02-28", limit = 250, format = "list")  # worked
# 
# 
# # for (i in 21:28) { # February
# #   Sys.sleep(runif(1, 5, 10))
# #   bioarxivfeb[[i]] <- biorxiv_content(from = paste0("2020-02-", i), to = paste0("2020-02-", i), limit = 200, format = "list")  
# # }
# 
# copyfeb <- bioarxivfeb
# bioarxivfeb <- copyfeb
# for (i in seq(bioarxivfeb)) {
#   bioarxivfeb[[i]] <- data.frame(matrix(unlist(bioarxivfeb[[i]]), nrow = length(bioarxivfeb[[i]]), byrow = T), stringsAsFactors=FALSE)
# }
# bioarxivfeb <- bind_rows(bioarxivfeb, .id = "column_label")
# 
# 
# #---------------------------------------------------------------------------------------------------------------------------------------
# # March 1-15 -->
# 
# bioarxivmarch <- list()
# for (i in 1:9) { # December
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivmarch[[i]] <- biorxiv_content(from = paste0("2020-03-0", i), to = paste0("2020-03-0", i), limit = 200, format = "list")  
# }
# bioarxivmarch[[5]] <- biorxiv_content(from = "2020-03-05", to = "2020-03-05", limit = 300, format = "list")  # worked
# 
# for (i in 10:15) { # December
#   Sys.sleep(runif(1, 5, 10))
#   bioarxivmarch[[i]] <- biorxiv_content(from = paste0("2020-03-", i), to = paste0("2020-03-", i), limit = 200, format = "list")  
# }
# 
# 
# 
# for (i in seq(bioarxivmarch)) {
#   bioarxivmarch[[i]] <- data.frame(matrix(unlist(bioarxivmarch[[i]]), nrow = length(bioarxivmarch[[i]]), byrow = T), stringsAsFactors=FALSE)
# }
# bioarxivmarch <- bind_rows(bioarxivmarch, .id = "column_label")
# 
# 
# biorxiv <- rbind(bioarxivdec, bioarxivjan, bioarxivfeb, bioarxivmarch)
# biorxiv$column_label <- NULL
# save(biorxiv, file = paste0(yourpath, "biorxivfull_", update, ".Rda"))
# 
# 
# #---------------------------------------------------------------------------------------------------------------------------------------
# # APPENDING
# 
# 
# biorxiv$X2 <- gsub("uncover", "", tolower(biorxiv$X2))
# biorxiv$X10 <- gsub("uncover", "", tolower(biorxiv$X10))
# 
# biorxiv$v1 <- ifelse(grepl("2019-ncov", tolower(biorxiv$X2)) | 
#                         grepl("covid", tolower(biorxiv$X2)) |
#                         grepl("ncov", tolower(biorxiv$X2)) |
#                         grepl("corona", tolower(biorxiv$X2)) |
#                         grepl("covid-2019", tolower(biorxiv$X2)) |
#                         grepl("covid-19", tolower(biorxiv$X2)) |
#                         grepl("covid19", tolower(biorxiv$X2)) |
#                         grepl("19covid", tolower(biorxiv$X2)) |
#                         grepl("19-covid", tolower(biorxiv$X2)) |
#                         grepl("2019-covid", tolower(biorxiv$X2)) |
#                         grepl("coronavirus", tolower(biorxiv$X2)) |
#                        grepl("sars-cov-2", tolower(biorxiv$X2)) |
#                        grepl("2019-ncov", tolower(biorxiv$X10)) | 
#                        grepl("covid", tolower(biorxiv$X10)) |
#                        grepl("ncov", tolower(biorxiv$X10)) |
#                        grepl("corona", tolower(biorxiv$X10)) |
#                        grepl("covid-2019", tolower(biorxiv$X10)) |
#                        grepl("covid-19", tolower(biorxiv$X10)) |
#                        grepl("covid19", tolower(biorxiv$X10)) |
#                        grepl("19covid", tolower(biorxiv$X10)) |
#                        grepl("19-covid", tolower(biorxiv$X10)) |
#                        grepl("2019-covid", tolower(biorxiv$X10)) |
#                        grepl("coronavirus", tolower(biorxiv$X10)) |
#                        grepl("sars-cov-2", tolower(biorxiv$X10))
#                        , 1, 0)
# biorxivcovid <- biorxiv[biorxiv$v1 == 1,]
# 
# require(data.table)
# biorxivcovid <- data.table(biorxivcovid)
# biorxivcovid <- biorxivcovid[biorxivcovid[, .I[X7 == max(X7)], by=X1]$V1]
# save(biorxivcovid, file = paste0(yourpath, "biorxivcovid_", update, ".Rda"))
# 
# #biorXiv
# for (i in 1:nrow(biorxivcovid)) {
#   
#   download.file(paste0("https://www.biorxiv.org/content/", biorxivcovid[i,1], "v", biorxivcovid[i,7], ".full.pdf"), paste0(yourpathtopdfs, "biorxiv_", i, "_", biorxivcovid[i,4], ".pdf"), mode = "wb")
#   
# }









