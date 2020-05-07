
dada2_match_rrndb <- function(tax, rrndb, .parallel = F) {
  if (.parallel == T) {
    if (exists("cl") == F) {
      stop(
        "Define cluster for parallel computing with `detectCores()` and `makeCluster()`."
      )
    }
    
    do.call("rbind",
            pbapply::pbapply(
              cl = cl,
              X = tax,
              MARGIN = 1,
              FUN = dada2.rrndb,
              rrndb = rrndb
            ))
  } else {
    # normal version
    do.call("rbind",
            pbapply::pbapply(
              X = tax,
              MARGIN = 1,
              FUN = dada2.rrndb,
              rrndb = rrndb
            ))
  }
}