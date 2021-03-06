#' Retrieve the number of database links from Europe PMC publication database
#'
#' This function returns the number of EBI database links associated with a
#' publication.
#'
#' @details Europe PMC supports cross-references between literature and the
#'   following databases:
#'   \describe{
#'  \item{'CHEBI'}{a database and ontology of chemical entities of biological
#'      interest \url{http://www.ebi.ac.uk/chebi/}}
#'   \item{'CHEMBL'}{a database of bioactive drug-like small molecules
#'      \url{https://www.ebi.ac.uk/chembldb/}}
#'   \item{'EMBL'}{now ENA, provides a comprehensive record of the world's
#'      nucleotide sequencing information \url{http://www.ebi.ac.uk/ena/}}
#'   \item{'INTACT'}{provides a freely available, open
#'      source database system and analysis tools for molecular interaction data
#'      \url{http://www.ebi.ac.uk/intact/}}
#'   \item{'INTERPRO'}{provides functional analysis of proteins by classifying
#'      them into families and predicting domains and important sites
#'      \url{http://www.ebi.ac.uk/interpro/}}
#'   \item{'OMIM'}{a comprehensive and authoritative compendium of human genes and
#'      genetic phenotypes \url{http://www.ncbi.nlm.nih.gov/omim}}
#'   \item{'PDB'}{European resource for the collection,
#'      organisation and dissemination of data on biological macromolecular
#'      structures \url{http://www.ebi.ac.uk/pdbe/}}
#'   \item{'UNIPROT'}{comprehensive and freely accessible
#'      resource of protein sequence and functional information
#'   \url{http://www.uniprot.org/}}
#'   }
#'
#' @param ext_id character, publication identifier
#' @param data_src character, data source, by default Pubmed/MedLine index will
#'   be searched.
#' @return data.frame with counts for each database
#' @export
#' @examples
#'   \dontrun{
#'   epmc_db_count(ext_id = "10779411")
#'   epmc_db_count(ext_id = "PMC3245140", data_src = "PMC")
#'   }
epmc_db_count <- function(ext_id = NULL, data_src = "med") {
  if (is.null(ext_id))
    stop("Please provide a publication id")
  if (!tolower(data_src) %in% supported_data_src)
    stop(
      paste0(
        "Data source '",
        data_src,
        "' not supported. Try one of the
        following sources: ",
        paste0(supported_data_src, collapse = ", ")
      )
    )
  # build request
  path <- paste(rest_path(), data_src, ext_id, "databaseLinks",
                "/json", sep = "/")
  doc <- rebi_GET(path = path)
  if (is.null(doc$dbCountList)) {
    message("Nothing found")
    NULL
  } else {
    plyr::rbind.fill(doc$dbCountList) %>%
      dplyr::as_data_frame()
  }
}
