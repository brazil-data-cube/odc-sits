library(sits)
library(odcsits)

#
# general definitions
#
classification_memsize    <- 16
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
# Search ODC Datasets
#
roi         <- readRDS(url("https://brazildatacube.dpi.inpe.br/geo-knowledge-hub/bdc-article/roi/roi.rds"))
sample_file <- "https://brazildatacube.dpi.inpe.br/public/bdc-article/training-samples/training-samples.csv"

datasets <- odc_search(
  odc_index  = index,
  collection = "CB4_64_16D_STK_1",
  start_date = "2018-09-01",
  end_date   = "2019-08-01"
)

#
# Generate the data cube
#
cube <- odc_cube(index, "CBERS-4", "AWFI", datasets)
cube$timeline[[1]][[1]] <- sort(cube$timeline[[1]][[1]])

#
# Extract time series
#
samples <- sits_get_data(cube, file = sample_file)
saveRDS(samples, file = "samples/bdc_paper_samples_ts.rds")

#
# Train model
#
rfor <- sits_train(samples, ml_method = sits_rfor(num_trees = 1000))

#
# Classify using the data cubes
#
probs <- sits_classify(
  data       = cube,
  ml_model   = rfor,
  memsize    = classification_memsize,
  multicores = classification_multicores,
  roi        = roi$classification_roi)

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
  labels, file = paste0("labels.rds")
)

# Probs
saveRDS(
  probs, file = paste0("probs_cube.rds")
)

# Smoothed probs
saveRDS(
  probs_smoothed, file = paste0("probs_smoothed_cube.rds")
)
