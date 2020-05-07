dada2.rrndb <- function(x, rrndb) {
  if (all(names(x) %in% levels(factor(rrndb$rank)) ==  F)) {
    stop("Rank names do not match.")
  }
  
  sub <- x[!is.na(x)]
  if(length(sub) == 0L){
    data.frame(
      x,
      class.rank = "no.match",
      copy.number = NA,
      stringsAsFactors = F
    )
  } else {
    names(sub) <- names(x)[1:length(sub)]
    class.rank <- names(sub)[length(sub)]
    match.rrndb <-
      rrndb[rrndb$rank == class.rank &
              rrndb$name == sub[class.rank],]
    if (nrow(match.rrndb) == 0L) {
      while (nrow(match.rrndb) == 0L) {
        class.rank <- names(sub)[which(names(sub) == class.rank) - 1]
        match.rrndb <-
          rrndb[rrndb$rank == class.rank &
                  rrndb$name == sub[class.rank],]
      }
    }
    
    data.frame(
      x,
      class.rank = match.rrndb$rank,
      copy.number = match.rrndb$mean,
      stringsAsFactors = F
    )
  }
}