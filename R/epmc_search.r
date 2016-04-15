#' Search Europe PMC publication database
#'
#' @description This is the main function to search
#' Europe PMC RESTful Web Service (\url{http://europepmc.org/RestfulWebService})
#'
#' @seealso \url{http://europepmc.org/Help}
#'
#' @param query search query (character vector). For more information on how to
#'   build a search query, see \url{http://europepmc.org/Help}
#' @param id_list Should only IDs (e.g. PMID) and sources be retrieved for the
#'   given search terms?
#' @param n_pages Number of pages to be returned. By default, this function
#'   returns 25 records for each page.
#' @return List of two, number of hits and the retrieved metadata as data.frame
#' @examples \dontrun{
#' #Search articles for 'Gabi-Kat'
#' my.data <- epmc_search(query='Gabi-Kat')
#'
#' #Get article metadata by DOI
#' my.data <- epmc_search(query = 'DOI:10.1007/bf00197367')
#'
#' #Get article metadata by PubMed ID (PMID)
#' my.data <- epmc_search(query = 'EXT_ID:22246381')
#'
#' #Get only PLOS Genetics article with EMBL database references
#' my.data <- epmc_search(query = 'ISSN:1553-7404 HAS_EMBL:y')
#' }
#' @export

epmc_search <- function(query = NULL, id_list = FALSE, n_pages = 50){
  # check
  if (is.null(query))
    stop("No query provided")
  if (!is.numeric(n_pages))
    stop("n_pages must be of type 'numeric'")
  path = paste0(rest_path(), "/search")
  q <- list(query = query, format = "json")
  doc <- rebi_GET(path = path, query = q)
  hitCount <- doc$hitCount
  if(hitCount == 0)
    stop("nothing found, please check your query")
  no_pages <- rebi_pageing(hitCount = hitCount, pageSize = doc$request$pageSize)
  # limit number of pages that will be retrieved
  if(max(no_pages) > n_pages) no_pages <- 1:n_pages
  pages = list()
  for(i in no_pages){
    if(!id_list) {
      out <- rebi_GET(path = path,
                      query = list(query = query,format = "json", page = i))
      } else {
        out <- rebi_GET(path = path,
                        query = list(query = query, format = "json", page = i,
                                     resulttype ="idlist"))
      }
    message("Retrieving page ", i)
    result <- plyr::ldply(out$resultList, data.frame,
                          stringsAsFactors = FALSE, .id = NULL)
    pages[[i+1]] <- result
    }
  #combine all into one
  result <- jsonlite::rbind.pages(pages)
  # remove nested lists from data.frame, get these infos with epmc_details
  md <- result[, !(names(result) %in% fix_list(result))]
  # return
  list(hit_count = hitCount, data = md)
}
