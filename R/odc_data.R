#' @title Open Data Cube Products
#'
#' @rdname odc_products
#'
#' @description Lists the products that are available for use in the queried
#' Open Data Cube instance.
#'
#' @param index  a \code{tibble} object from class \code{odcsits-index} with
#'               Open Data Cube Database valid connection.
#'
#' @param ...    parameters passed to \code{DBI::dbGetQuery} function to
#'               control the connection made with Open Data Cube Database
#'
#' @export
odc_products <- function(index, ...) {

  if (!inherits(index, "odcsits-index"))
    .error(paste("The given `index` does not correspond to a Open Data Cube Database Index",
                 "Please use the `odc_index` function to create a valid index"))

  query <- "SELECT name AS id,
                   definition ->> 'description' AS description
            FROM agdc.dataset_type;"

  DBI::dbGetQuery(
    index$database_index, query, ...
  )
}

#' @title Open Data Cube Datasets Search
#'
#' @rdname odc_search
#'
#' @description Searches datasets of a Product in an Open Data Cube instance.
#' The search can consider both spatial and temporal information.
#'
#' @param index      a \code{tibble} object from class \code{odcsits-index} with
#'                   Open Data Cube Database valid connection.
#' @param product    Name of the product that will be searched in the Open Data Cube.
#' @param start_date Initial date for the search data
#' @param end_date   Final date for the search data
#' @param bbox       Area of interest (see details below)
#' @param ...        parameters passed to \code{DBI::dbGetQuery} function to
#'                   control the connection made with Open Data Cube Database
#'
#' @details  The "bbox" parameters allows a selection of an area of interest.
#' Either using a named \code{vector} ("xmin", "ymin", "xmax", "ymax") with
#' values in WGS 84.
#'
#' @export
odc_search <- function(index, product, start_date, end_date, bbox = NULL, ...) {

  if (!inherits(index, "odcsits-index"))
    .error(paste("The given `index` does not correspond to a Open Data Cube Database Index",
                 "Please use the `odc_index` function to create a valid index"))

  if (any(!is.null(start_date) | !is.null(end_date)))
    .check_datetime(start_date, end_date)

  # query predicates
  product <- sprintf("product = '%s'", product)
  start_date <- sprintf("date >= '%s'", start_date)
  end_date   <- sprintf("date <= '%s'", end_date)

  if(!is.null(bbox))
    bbox <- sprintf(
      "AND ST_Intersects(geom, ST_MakeEnvelope(%f, %f, %f, %f, 4326))",
      bbox$xmin, bbox$ymin, bbox$xmax, bbox$ymax
    )
  else
    bbox <- ''

  # build query
  query <- sprintf(
    "SELECT
        id,
        product,
        date,
        geom
    FROM
      tmp_dataset_collection_sits_odc
    WHERE
    %s AND %s AND %s %s;",
    start_date, end_date, product, bbox
  )

  # get datasets
  datasets <- DBI::dbGetQuery(
    index$database_index, query, ...
  )

  datasets_files <- NULL
  if (nrow(datasets) > 0) {
    uuids <- paste(datasets$id, collapse = ",")
    datasets_files <- DBI::dbGetQuery(
      index$database_index,
      sprintf(
        "SELECT
                  *
              FROM
                  tmp_dataset_collection_sits_odc
              WHERE
                  id LIKE ANY('{%s}');",
        uuids
      )
    )
  }

  .build_odcsits_tb(
    datasets, datasets_files
  )
}
