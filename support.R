require(reshape2)
require(digest)

jointseed <- function(datein,string) {
  # Not intended for cryptographic security. Instead we want the seed to
  # be reproducible/predictable for a certain combination of day and check
  # to be performed, while avoiding patterns (e.g. using just date would result
  # in same random patterns selected for all checks, adding offset to single seed
  # would cause days close together to have the same patterns)
  # Note it will set seed as an intermediate state, so calling it will reset the
  # RNG. First step stackoverflow #10910698
  seed1 <- as.numeric(paste0("0x",digest(string,"crc32"))) %% .Machine$integer.max
  set.seed(seed1)
  seed2 <- as.numeric(datein + sample(1:10000,1)) %% .Machine$integer.max
  seed2
}


readInput <- function(filename) {
  fields <- c("label","brainA","brainB","brainchange","ventA","ventB","ventchange");
  loaderr <- FALSE
  errmsg <- ""
  indata <- read.csv(filename, stringsAsFactors = FALSE, header = TRUE)

  if (sum(fields %in% colnames(indata)) != length(fields)) {
    errmsg <-"Input file missing required fields"
    loaderr <- TRUE
  }
  if (!loaderr &
      any(sapply(fields, function(x){x!="label" & !is.numeric(indata[,x])}))){
    errmsg <- "Some result columns in input file are not numeric"
  }
  if (loaderr) {
    errmsg
  } else {
    indata
  }
}

buildInput <- function(indata, which) {
  # Get desired values (which=brain/vent) from the full input data
  # calculate difference in measured volumes (different from measured change)
  types <- c("A","B","change")
  errs <- FALSE
  if ( ! which %in% c("vent","brain")) {
    return ("Tried to get unrecognised volume type")
  }
  fields <- paste0(which,types)
  names(fields)<-types
  outdata <- data.frame(label=indata$label, volA=indata[,fields["A"]],
                   volB=indata[,fields["B"]], change=indata[,fields["change"]])
  outdata$volDelta <- outdata$volB - outdata$volA
  outdata
}

outliers <- function(builtdata, type, lower.tail=0, upper.tail=0, inliers=0) {
  # type = vol/change
  # Tails and inliers specified as proportion of the data to list as outliers.
  # Return list of labels and types (for type=vol returned types are volA/volB)
  # and value to be checked.
  # Can't exclude more than all the data.
  lower.tail <- min(max(lower.tail,0),1)
  upper.tail <- min(max(upper.tail,0),1-lower.tail)
  inliers <-    min(max(inliers,0),1-(lower.tail+upper.tail))
  if ( ! type %in% c("vol","change")) {
    return ("Tried to get unrecognised value type for outliers")
  }
  # Long format with result label and the variables to range check across
  getvals <- if(type=="vol") {
    c("volA","volB")
  } else {
    type
  }
  checkvals <- melt(builtdata, id.vars="label", measure.vars=getvals)
  # Find the outliers in tails
  rangelim <- quantile(checkvals$value,probs=c(lower.tail, 1-upper.tail))
  checkvals$outlier <- findInterval(checkvals$value,rangelim,
                                    rightmost.closed = TRUE) != 1
  # Find the random inliers to check
  inlierInd <- which(!checkvals$outlier)
  inliersN <- min(inliers*nrow(checkvals), length(inlierInd))
  checkind <- sample(inlierInd, inliersN)
  checkvals$incheck <- FALSE
  checkvals$incheck[checkind] <- 1
  checkvals$allcheck <- checkvals$incheck | checkvals$outlier
  checkvals[checkvals$allcheck,c("label","variable","value")]
}


#testin <- readInput("data/test1.csv")
#bi <- buildInput(testin,"vent")
#ol<-outliers(bi,"vol",upper.tail=0.02, lower.tail=0.02, inliers=0.01)
#bi2$check<-ifelse(bi2$label %in% ol$label, "check","okay")
#library(ggplot2)
#qplot(x=volDelta,change,data=bi2,colour=check)

#plot(res$brainDelta,res$brainchange)
#plot(res$brainDelta,res$brainchange, col=res$outlier+1)
# vol outliers
## vollim <- quantile(c(res$brainA,res$brainB),probs=c(qlim,1-qlim))
# res$voloutlier <- findInterval(res$brainA,vollim) != 1 || findInterval(res$brainB,vollim) != 1
