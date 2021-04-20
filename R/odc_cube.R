#' @title ODC Complete Cube
#'
#' @rdname odc_cube
#'
#' @description ...
#'
#' @param odc_index ...
#' @param satellite ...
#' @param sensor ...
#' @param datasets ...
#'
#' @export
odc_cube <- function(odc_index, satellite, sensor, datasets, parser = bdc_parser())
{
    if (!.check_parser(parser))
        .error("Parser is not valid! Please define `delim` and `parse_info`")

    uuids <- paste(datasets$id, collapse = ",")
    rs    <- DBI::dbSendQuery(
        odc_index,
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
    datasets_reference <- DBI::dbFetch(rs)

    # create the data cube
    bands_directory <-
        lapply(datasets_reference$bands, function(row) {
            dirname(jsonlite::parse_json(row)[[1]]$path)
        })

    cube <- sits::sits_cube(
        type = "STACK",
        satellite = satellite,
        sensor = sensor,
        data_dir = unlist(bands_directory),
        delim = parser$delim,
        parse_info = parser$parse_info
    )
}


#' @title ODC Brick Cube
#'
#' @rdname odc_brick
#'
#' @description ...
#'
#' @param odc_index ...
#' @param satellite ...
#' @param sensor
#' @param datasets ...
#' @param ... ...
#'
#' @export
#' @export
odc_brick <- function(odc_index, satellite, sensor, datasets, ...) {
    uuids <- paste(datasets$id, collapse = ",")
    rs    <- DBI::dbSendQuery(odc_index, sprintf("SELECT
                                              *
                                          FROM
                                              tmp_dataset_collection_sits_odc
                                          WHERE
                                              id LIKE ANY('{%s}');", uuids))
    datasets_reference <- DBI::dbFetch(rs)

    # create the data cube
    base_dir  <- tempdir()

    tiles_brick <-
        lapply(unique(datasets_reference$date), function(date_row) {
            brick_reference <-
                datasets_reference[datasets_reference$date == date_row, ]

            # brick in ODC use `path` and `layer` fields
            brick_bands_file <- as.data.frame(do.call(rbind, lapply(
                jsonlite::stream_in(textConnection(
                    gsub("\\n", "", brick_reference$bands)
                )), as.vector
            )))

            brick_bands_file <-
                brick_bands_file[order(unlist(brick_bands_file$layer)), ]

            # for each band, group tile and create a vrt
            rbind(by(brick_bands_file, brick_bands_file$layer, function(x) {
                layerref  <- unique(x$layer)
                layername <- strsplit(rownames(x)[1], ".1")[[1]]

                gdalfiles <-
                    unlist(lapply(strsplit(x$path, "file://"), function(x)
                        x[2]))

                vrt_file <-
                    paste(base_dir,
                          "/",
                          basename(strsplit(gdalfiles[1], split = ".tif")[[1]][1]),
                          "_",
                          layername,
                          ".vrt",
                          sep = "")

                gdalUtils::gdalbuildvrt(gdalfile   = gdalfiles,
                                        output.vrt = vrt_file,
                                        b    = layerref, tr = c(30, 30))
                vrt_file
            }))
        })

    sits::sits_cube(
        type = "STACK",
        satellite = satellite,
        sensor = sensor,
        data_dir = base_dir,
        ...
    )
}
