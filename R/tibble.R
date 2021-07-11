#' @title Build odc-sits tibble
#'
#' @description Creates a list of the odcsits class. The "dataset" and
#' "dataset_files" information is transformed into \code{tibble::tibble}.
#'
#' @param datasets a \code{data.frame} from Open Data Cube Database
#' @param datasets_files a \code{data.frame} from Open Data Cube Database
#'
#' @return a \code{tibble} with database data.
.build_odcsits_tb <- function(datasets, datasets_files) {

  structure(
    list(
      datasets = tibble::as_tibble(datasets),
      datasets_files = tibble::as_tibble(datasets_files)
    ), class = "odcsits"
  )
}
