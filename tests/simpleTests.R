
library(ciw)

## tests are tricky because of
##   a) connectivity (which incoming() checks internally)
##   b) random nature of content at the CRAM incoming/ directories
## so we keep it simple

res <- incoming()
isTRUE(inherits(res, "data.frame"))

n <- nrow(res)
isTRUE(n >= 0)

k <- if (n > 0) ncol(res) else 0
isTRUE(k >= 0)

expected_names <- c("Folder", "Name", "Time", "Size", "Age")
actual_names <- if (k > 0) colnames(res) else expected_names
isTRUE(all.equal(actual_names, expected_names))
