#' @title Metadata View
#' @name metadata query view
#'
#' @description ...
#'
#' @export
.odc_query_view <- function()
{
  "
  CREATE TEMPORARY VIEW tmp_dataset_collection_sits_odc AS (
	SELECT
		dataset_type.name AS collection,
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

#' @title ODC Products Search
#'
#' @rdname odc_index
#'
#' @description ...
#'
#' @param dbname ...
#' @param host ...
#' @param port ...
#' @param user ...
#' @param password ...
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

  conn
}
