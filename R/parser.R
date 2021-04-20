
#' @title Brazil Data Cube File Parser Metadata
#'
#' @rdname bdc_parser
#'
#' @description ...
#'
#' @param odc_index ...
#' @param satellite ...
#' @param sensor ...
#' @param datasets ...
#'
#' @export
bdc_parser <- function() {
  list(
    delim      = "_",
    parse_info = c("sat", "res", "X1", "X2", "X3", "tile", "date", "X4", "band")
  )
}
