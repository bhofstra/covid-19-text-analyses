#############################################
# Author:   Bas Hofstra                     #
# Dates:    17-03-2020                      #
#           07-04-2020                      #
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
require(data.table)

# initiating
yourpath <- "xxx"
yourpathtopdfs <-  "xxx"
update <- "20200407"

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
for (i in 2:127) {
  
  Sys.sleep(runif(1, 1, 5))
  
  urllist[[i]] <- paste0("https://connect.medrxiv.org/relate/content/181?page=", i)
  
  doclist[[i]] <- read_html(urllist[[i]])
  
  urls[[i]] <- html_attr(html_nodes(doclist[[i]], "a"), "href")
  #urls[[i]] <- urls[[i]][c(7:26), ]
  #urls[[i]] <-  as.character(urls[[i]])
  
}

vector <- unlist(urls)
vector <- unique(vector)
#pap <- bind_rows(urls, .id = "column_label")


vector <- vector[-grep("page=", vector)]
vector <- vector[-grep("collection", vector)]
vector <- vector[-grep("relate", vector)]
vector <- vector[-grep("alertsrss", vector)]
vector <- vector[-c(1:5)]




# and the first first page
url <- "https://connect.medrxiv.org/relate/content/181"
doc <- read_html(url)
doc <- html_attr(html_nodes(doc, "a"), "href")
doc <- unique(doc[7:26])


  
# combine first and later pages
# so these are all the links!
paper <- c(doc, vector)
           
      
#------------------------------------------------------------------------------------------
# 2 From those links download website urls
#------------------------------------------------------------------------------------------

# get htmls
doclist <- list()

for (i in 1012:1264) {
  
  Sys.sleep(runif(1, 1, 2))
  doclist[[i]] <- read_html(paper[i])
  
}

#------------------------------------------------------------------------------------------
# 3 From those websites get pdf urls
#------------------------------------------------------------------------------------------

# find pdf urls in the xml files?
pdfurl <- list()
for (i in 704:1264) {
 
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

# metatitles <- list()
# metaabstract <- list()
# metadoi <- list()
# metadate <- list() 
# firstnames <- list()
# lastnames <- list()
for (i in 704:1264) {

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
  
  metadate[[i]] <- doclist[[i]] %>% # title
                        rvest::html_nodes('body') %>%
                        xml2::xml_find_all("//div[contains(@class, 'panel-pane pane-custom pane-1')]") %>%
                        rvest::html_text()
  metadate[[i]] <-  gsub("\n", "", metadate[[i]])
  metadate[[i]] <-  gsub("Posted", "", metadate[[i]])
  metadate[[i]] <-  gsub(",", "", metadate[[i]])
  metadate[[i]] <-  gsub("\\.", "", metadate[[i]])
  metadate[[i]] <-  trimws(metadate[[i]], which = c("both"))
  metadate[[i]] <-  trimws(metadate[[i]], which = c("left"))
  
}

# build dataset am lazy can do way more efficient but this works for now
huh <- as.data.frame(cbind(as.data.frame(unlist(metatitles)), as.data.frame(unlist(metaabstract)), 
                           as.data.frame(unique(unlist(metadoi))), as.data.frame(unlist(metadate)),
                           as.data.frame(unlist(firstnames)), as.data.frame(unlist(lastnames)), as.data.frame(unlist(pdfurl))))
names(huh) <- c("title", "abstract", "doi", "posted", "authorfirstnames", "authorlastnames", "pdfurl") # with logical names

# I trippled the authornames with the xml parse, so collapse on uniques.
huh$authorlastnames <- sapply(strsplit(as.character(huh$authorlastnames), ";", fixed = TRUE), function(x) 
                        paste(unique(x), collapse = ";"))

# Nice thing is that I have first and last names separated
# can we infer some things from these authors? Probably, study later on.
huh$authorfirstnames <- sapply(strsplit(as.character(huh$authorfirstnames), ";", fixed = TRUE), function(x) 
                        paste(unique(x), collapse = ";"))



# save metadata
save(huh, file = paste0(yourpath, "bio_med_rxivcovid_", update, ".RDa"))

#------------------------------------------------------------------------------------------
# 5 Download pdfs
#------------------------------------------------------------------------------------------

# so here a loop to download pdfs
huh$pdfurl <- as.character(huh$pdfurl)

for (i in 1:nrow(huh)) {
  
  Sys.sleep(runif(1, 1, 3))
  
  if (http_error(huh[i,7])) { # if there is an error, then its biorxiv
    download.file(gsub("medrxiv", "biorxiv", huh[i, 7]), # so gsub medrxiv to biorxiv in order to get the good link!
                  paste0(yourpathtopdfs, "biorxiv_", i, "_", trimws(sub('.*\\/', '', huh[i,3]), "right"), ".pdf"), mode = "wb")
    }
  else { # no error means it's medrxiv!
    download.file(huh[i, 7], # so just the link we've extracted
                  paste0(yourpathtopdfs, "medrxiv_", i, "_", trimws(sub('.*\\/', '', huh[i,3]), "right"), ".pdf"), mode = "wb")
    }
  
}




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
corona2 <- corona2[-c(145:147), ] # Papers that are too early

arxivcovid <- rbind(covid1, covid2, covid3, corona1, corona2, ncov2)
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



#------------------------------------------------------------------------------------------
# xxx tiny viz
#------------------------------------------------------------------------------------------

# get posting date
huh$date <- trimws(sub('.*\\/', '', huh$doi), "right")
huh$date <- sub(".[^.]+$", "",  huh$date)
huh$date <- gsub("\\.", "", huh$date)

arxivcovid$date <- substr(arxivcovid$updated, 1, 10)
arxivcovid$date <- gsub("-", "", arxivcovid$date)

huppa <- as.data.frame(append(huh$date, arxivcovid$date))

tab <- data.frame(table(huppa[,1]))


f1 <- ggplot(tab, aes(x=Var1, y = cumsum(Freq))) + 
  xlab("Date") + ylab("") + 
  geom_line(group = 1) +
  theme_bw() + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, size = 4),
        axis.text.y = element_text(size = 6),
        axis.title = element_text(size = 8)) + ggtitle("Research papers on Covid-19 over time (bio/med/arxiv")

ggsave("f1.png", plot = f1, device = "png", path = "/Users/bashofstra/desktop",
       scale = 1, width = 14, height = 7, units = c("cm"),
       dpi = "retina")





