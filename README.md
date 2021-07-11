
<!-- README.md is generated from README.Rmd. Please edit that file -->

## odc-sits - SITS-based R Client Library for Open Data Cube

<!-- badges: start -->

[![Software
License](https://img.shields.io/badge/license-MIT-green)](https://github.com/brazil-data-cube/odc-sits/blob/master/LICENSE)
[![Software Life
Cycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Join us at
Discord](https://img.shields.io/discord/689541907621085198?logo=discord&logoColor=ffffff&color=7389D8)](https://discord.com/channels/689541907621085198#)

<!-- badges: end -->

[Open Data Cube](https://www.opendatacube.org/) is a system designed to
manage Spatio-temporal Earth Observation Data Cubes.

The `odc-sits` package is an experimental R Client for the Open Data
Cube ecosystem. The Data Cube representation performed by `odc-sits` is
based on the [SITS package](https://github.com/e-sensing/sits). This
pairing gives the possibility of using ODC data products in Satellite
Image Time Series Classification.

## Installation

To install the development version of `odc-sits`, run the following
commands:

``` r
# load necessary libraries
library(devtools)
devtools::install_github("brazil-data-cube/odc-sits")
```

Importing `odc-sits` package:

``` r
library(odcsits)
```

## Usage

`odc-sits` implements the following WLTS operations:

| Operation                     | `odc-sits` functions |
|:------------------------------|:---------------------|
| `List ODC Products Available` | `odc_products`       |
| `Search ODC Datasets`         | `odc_search`         |
| `Create a ODC Data Cube`      | `odc_cube`           |
