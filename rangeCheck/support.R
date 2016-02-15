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


# Read a supplied file, check it has all our required fields and types.
# Return a data frame if okay, otherwise return errors as strings, 
readInput <- function(filename) {
  fields <- c("label","brainA","brainB","brainchange","ventA","ventB","ventchange");
  loaderr <- FALSE
  errmsg <- ""
  tryCatch(
    indata <- read.csv(filename, stringsAsFactors = FALSE, header = TRUE),
    error = function(x) { loaderr <<- TRUE ; errmsg <<- "Failed loading file"}
  )

  if (!loaderr &&
      sum(fields %in% colnames(indata)) != length(fields)) {
    errmsg <-"Input file missing required fields"
    loaderr <- TRUE
  }
  if (!loaderr &&
      any(sapply(fields, function(x){x!="label" & !is.numeric(indata[,x])}))){
    errmsg <- "Some result columns in input file are not numeric"
    loaderr <- TRUE
  }

  if (! loaderr &&
      length(unique(indata[,"label"])) != nrow(indata)) {
    errmsg <- "Row labels are not unique."
    loaderr <- TRUE
  }
  if (loaderr) {
    errmsg
  } else {
    indata[,fields]
  }
}

# Get desired values (which=brain/vent) from the full input data
# calculate difference in measured volumes (different from measured change)
# Return a data frame or errors as strings.
buildInput <- function(indata, which) {
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


# type = vol/change
# Tails and inliers specified as proportion of the data to list as outliers.
# NA values are included in the checking set, unless dropNA=TRUE, but number of
# rows to return for each tail and inliers is still calculated as a proportion
# of full data (that is, NA are reported as extra checks).
# Return list of labels and types (for type=vol returned types are volA/volB)
# and value to be checked.
outliers <- function(builtdata, type, lower.tail=0, upper.tail=0, inliers=0,
                     dropNA=FALSE) {
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
  checkvals$checkna <- (! dropNA) * is.na(checkvals$value)
  # Find the outliers in tails
  rangelim <- quantile(checkvals$value,probs=c(lower.tail, 1-upper.tail),
                       na.rm=TRUE)
  checkvals$outlier <- findInterval(checkvals$value,rangelim,
                                    rightmost.closed = TRUE) != 1
  # Find the random inliers to check
  inlierInd <- which(!checkvals$outlier)
  inliersN <- min(inliers*nrow(checkvals), length(inlierInd))
  checkind <- sample(inlierInd, inliersN)
  checkvals$incheck <- FALSE
  checkvals$incheck[checkind] <- 1
  checkvals$allcheck <- checkvals$incheck | checkvals$outlier | checkvals$checkna
  checkvals[checkvals$allcheck,c("label","variable","value")]
}

# Aggressively sanitise input strings
cleanstring <- function(x) {
  gsub("[^A-Za-z0-9 _\\.-]","",x)
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
