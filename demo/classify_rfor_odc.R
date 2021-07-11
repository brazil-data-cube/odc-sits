library(sits)
library(odcsits)

#
# General definitions
#
classification_memsize    <- 6
classification_multicores <- 8

#
# Connect to ODC Metadata Database
#
index <- odc_index(
  dbname   = "my-odc-database",
  host     = "my-odc-host",
  port     = 5432,
  user     = "my-odc-user",
  password = "my-odc-passowrd"
)

#
# Load Sample file
#
sample_file <- "https://brazildatacube.dpi.inpe.br/public/bdc-article/training-samples/training-samples.csv"

#
# Search ODC Products
#
odc_products(index)

#
# Search ODC Datasets
#
datasets <- odc_search(
  index      = index,
  product    = "CB4_64_16D_STK_1",
  start_date = "2018-09-01",
  end_date   = "2019-08-01"
)

#
# Generate the ODC data cube
#
cube <- odc_cube("CBERS-4", "AWFI", datasets)

# SITS Usage!

#
# Extract time series
#
samples <- sits_get_data(cube,
                         file       = sample_file,
                         multicores = classification_multicores)

#
# Train model
#
rfor <- sits_train(
    samples, ml_method = sits_rfor(
        num_trees = 1000
    )
)

#
# Classify using the data cubes
#
probs <- sits_classify(
  data       = cube,
  ml_model   = rfor,
  memsize    = classification_memsize,
  multicores = classification_multicores
)

#
# Post-processing
#
probs_smoothed <- sits_smooth(probs, type = "bayes")
labels         <- sits_label_classification(probs_smoothed)

#
# Saving results
#

# Labels
saveRDS(
  labels, file = "labels.rds"
)

# Probs
saveRDS(
  probs, file = "probs_cube.rds"
)

# Smoothed probs
saveRDS(
  probs_smoothed, file = "probs_smoothed_cube.rds"
)
