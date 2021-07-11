#' @title Brazil Data Cube File Parser Metadata
#'
#' @rdname bdc_parser
#'
#' @description Example parser for extracting information from files used for
#' generating the \code{odc_cube}. This is the default parser used by
#' \code{odc-sits} when the data is loaded.
#'
#' @export
bdc_parser <- function() {
  list(
    delim      = "_",
    parse_info = c("sat", "res", "X1", "X2", "X3", "tile", "date", "X4", "band")
  )
}
