#' @title Open Data Cube data
#'
#' @rdname odc_cube
#'
#' @description Data cube created with data indexed in an Open Data Cube
#' instance. The construction of the data cube is based on the data structures
#' in the \code{sits} package.
#'
#' @note It is assumed that the data loaded by the \code{odc_cube} function is
#' aligned in time and space. If the data does not have these properties,
#' the function may have problems.
#'
#' @param satellite Satellite that produced the images. This name must match
#'                  the satellites that are declared in the \code{sits} package
#'                  configuration file. (see details below)
#' @param sensor    Sensor that produced the images. (see details below)
#' @param datasets  a \code{tibble} object from class \code{odcsits} with the
#'                  datasets that will be loaded from ODC instance to build
#'                  the data cube.
#' @param .parser   a \code{list} with parsing information for files.
#'
#' @details The "satellite" and "sensor" parameters must match the declarations
#' made in the \code{sits} package configuration file.
#'
#' @details The ".parser" it is an optional parameter that can be used to declare
#' the naming pattern of the files indexed by the Open Data Cube. This pattern
#' will be used to define the characteristics of the data cube that will
#' be generated. For this parameter a named \code{vector} ("delim", "parse_info")
#' is expected. The value of "delim" is used to determine the separator in the
#' name of the files loaded from the ODC. On the other hand, the "parse_info"
#' parameter determines what information is represented by each position in the
#' configuration file. For example, for the file name:
#'
#'    CB4_64_16D_STK_v001_022024_2019-10-16_2019-10-31_BAND15
#'
#' The ".parser" parameter will be:
#'
#' .parser = list(
#'  delim = "_",
#'  parse_info = c("sat", "res", "X1", "X2", "X3", "tile", "date", "X4", "band")
#' )
#'
#' This will split the file name using "_" and the positions have the meaning
#'  represented in "parse_info". In this case:
#'
#'   sat = CB4
#'   res = 64
#'   tile = 022024
#'   date = 2019-10-16_2019-10-31
#'   band = BAND15
#'
#' The "Xx" values represent values that should not be used.
#'
#' @export
odc_cube <- function(satellite, sensor, datasets, .parser = bdc_parser())
{
    if (!inherits(datasets, "odcsits"))
        .error(paste("The given `datasets` does not correspond to a Open Data Cube",
                "Please use the `odc_search` function. to retrieve valid datasets"))

    if (!.check_parser(.parser))
        .error("Parser is not valid! Please define `delim` and `parse_info`")

    # create the data cube
    bands_directory <-
        lapply(datasets$datasets_files$bands, function(row) {
            dirname(jsonlite::parse_json(row)[[1]]$path)
        })

    cube <- sits::sits_cube(
        source = "LOCAL",
        satellite = satellite,
        sensor = sensor,
        data_dir = unlist(bands_directory),
        delim = .parser$delim,
        parse_info = .parser$parse_info
    )
}
