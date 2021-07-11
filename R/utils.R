#' @title Check Parser
#'
#' @description Checks if an \code{list} is a valid parser.
#'
#' @param parse_args a \code{character} string with format warning message.
#'
#'
#' @noRd
.check_parser <- function(parse_args)
{
  all(c("delim", "parse_info") %in% names(parse_args))
}

#' @title Validates the dates
#' @name .check_datetime
#'
#' @description Checks if the dates are in RFC 3339 format and if they are in a
#'  valid start and end date relationship
#'
#' @param start_date \code{character} Start date in RFC 3339 format
#' @param end_date   \code{character} End date in RFC 3339 format
.check_datetime <- function(start_date, end_date) {

  pattern_rfc  <- "^\\d{4}-\\d{2}-\\d{2}?"
  check_status <- vapply(c(start_date, end_date), grepl,
                         pattern   = pattern_rfc,
                         perl      = TRUE,
                         FUN.VALUE = logical(1),
                         USE.NAMES = FALSE)

  if (!all(check_status))
    .error("The dates must be in the format of RFC 3339 (YYYY-MM-DD)")

  if (all(!is.null(start_date) & !is.null(end_date))) {
    if (start_date >= end_date)
      .error("The 'start_date' should be less than 'end_date'")
  }
}

#' @title Utility functions
#'
#' @param msg   a \code{character} string with format error message.
#'
#' @param ...   values to be passed to \code{msg} parameter.
#'
#' @noRd
.error <- function(msg, ...) {

  stop(sprintf(msg, ...), call. = FALSE)
}

#' @title Utility functions
#'
#' @param msg   a \code{character} string with format text message.
#'
#' @param ...   values to be passed to \code{msg} parameter.
#'
#' @noRd
.message <- function(msg, ...) {

  message(sprintf(msg, ...))
}

#' @title Utility functions
#'
#' @param msg   a \code{character} string with format warning message.
#'
#' @param ...   values to be passed to \code{msg} parameter.
#'
#' @noRd
.warning <- function(msg, ...) {

  warning(sprintf(msg, ...), call. = FALSE)
}
