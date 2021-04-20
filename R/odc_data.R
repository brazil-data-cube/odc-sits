#' @title ODC Products
#'
#' @rdname odc_cube
#'
#' @description ...
#'
#' @param odc_index ...
#'
#' @export
odc_products <- function(odc_index) {
  rs <- DBI::dbSendQuery(odc_index, "SELECT
                                  name AS id,
                                  definition ->> 'description' AS description
                              FROM agdc.dataset_type;")
  DBI::dbFetch(rs)
}

#' @title ODC Products Search
#'
#' @rdname odc_cube
#'
#' @description ...
#'
#' @param odc_index ...
#' @param collection ...
#' @param start_date ...
#' @param end_date ...
#' @param bbox ...
#'
#' @export
odc_search <- function(odc_index, collection, start_date, end_date, bbox = NULL) {

  # query predicates
  collection <- sprintf("collection = '%s'", collection)
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
        collection,
        date,
        geom
    FROM
      tmp_dataset_collection_sits_odc
    WHERE
    %s AND %s AND %s %s;",
    start_date, end_date, collection, bbox
  )

  DBI::dbFetch(
    DBI::dbSendQuery(odc_index, query)
  )
}
