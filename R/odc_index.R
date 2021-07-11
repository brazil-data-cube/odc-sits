#' @title Metadata View
#' @name metadata query view
#'
#' @description This function creates a temporary database view in the
#' Open Data Cube that makes it easy to search for other operations.
#' In addition, the created view provides spatio-temporal, bands, and CRS
#' information of the indexed datasets.
#'
#' @export
.odc_query_view <- function()
{
  "
  CREATE TEMPORARY VIEW tmp_dataset_collection_sits_odc AS (
	SELECT
		dataset_type.name AS product,
		dataset.metadata ->> 'id' AS id,
		ST_MakeEnvelope(
			(dataset.metadata -> 'extent' -> 'coord' -> 'll' -> 'lon')::float,
			(dataset.metadata -> 'extent' -> 'coord' -> 'll' -> 'lat')::float,
			(dataset.metadata -> 'extent' -> 'coord' -> 'ur' -> 'lon')::float,
			(dataset.metadata -> 'extent' -> 'coord' -> 'ur' -> 'lat')::float,
			4326
		) AS geom,
		(dataset.metadata -> 'grid_spatial' -> 'projection' -> 'spatial_reference')::text as crs,
		(dataset.metadata -> 'extent' ->> 'center_dt')::date AS date,
		dataset.metadata -> 'image' -> 'bands' AS bands
	FROM
		agdc.dataset AS dataset,
		agdc.dataset_type AS dataset_type
	WHERE
		dataset.dataset_type_ref = dataset_type.id);
  "
}

#' @title Open Data Cube Index
#'
#' @rdname odc_index
#'
#' @description Creates the connection to the Open Data Cube database.
#' This function generates a list of the class \code{odcsits-index} that allows
#' the connection to and manipulation of the database.
#'
#' @note It is recommended that the database information be stored in
#' environment variables, avoiding direct exposure of the user/password in the code.
#'
#' @param dbname Open Data Cube Database name
#' @param host Open Data Cube Database host
#' @param port Open Data Cube Database port
#' @param user Open Data Cube Database user
#' @param password Open Data Cube Database password
#'
#' @export
odc_index <- function(dbname, host, port, user, password) {
  conn <- DBI::dbConnect(
    drv      = RPostgres::Postgres(),
    dbname   = dbname,
    host     = host,
    port     = port,
    user     = user,
    password = password
  )

  # create a temporary view (client instance)
  DBI::dbSendQuery(conn, .odc_query_view())

  structure(
    list(
      database_index = conn
    ), class = "odcsits-index"
  )
}
