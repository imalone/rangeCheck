volumeDistrib <- function(n, midmean, midsd,
                         changemean, changesd, repeatsd, 
                         outlierscale, outlierprop, label){
  # Simulate a distribution of the following:
  # baseline and repeat volumes with a particular mean change
  # both should have similar standard deviations (i.e. unaffected by
  # variations in volume change, this reflects that different subjects
  # will be at different stages, so cross-sectional s.d. is roughly
  # timepoint independent). There should be an underlying change (corresponding
  # to a more accurate change measure), with a somewhat larger variation in
  # the volume differences. Finally all values in the final structure should
  # be subject to outlier noise, this is simulated by +/- samples from an
  # exponential distribution.
  
  mids <- rnorm(n, midmean, midsd)
  changes <- rnorm(n, changemean, changesd)
  deltas <- changes + rnorm(n, 0, repeatsd)
  bases <- mids - deltas / 2
  repeats <- mids + deltas / 2
  res <- cbind(bases, repeats, changes)
  colnames(res) <- paste0(label, c("A", "B", "change"))
  # Generate a non-gaussian distribution for the outliers.
  resn<-length(res)
  # Number of outliers is random:
  outliern <- rbinom(1,resn,outlierprop)
  # Outlier values:
  outliers <- rexp(outliern,1/outlierscale) * (-1)^rbinom(outliern,1,0.5)
  # Which values to apply to:
  outlierind <- sample(seq_along(res), outliern, replace=FALSE)
  res[outlierind] <- res[outlierind] + outliers
  data.frame(res)
}


simVent <- function(n) {
  volumeDistrib(n,54,25,5,3.3,3.5,10,0.1,"vent")
}

simBrain <- function(n) {
  res<-volumeDistrib(n,1000,115,-20,10,5,10,0.1,"brain")
}

simLabels <- function(n) {
  # Generate a set of unique labels for each row. Not really necessary,
  # (could just number them), but looks a bit more like real data.
  maxLabel = max(2*n, 26*26*10)-1
  labelVal <- sample(0:maxLabel, n, replace=FALSE)
  labelAlph <- paste0(LETTERS[labelVal%%26+1],LETTERS[labelVal%/%26%%26+1])
  labelN <- labelVal%/%26%/%26
  nDig <- ceiling(max(log10(labelN)))
  data.frame(label=paste0(labelAlph,sprintf("%0*d",nDig,labelN)))
#  nDig
#  labelVal
}

simDataSet <- function(n) {
  labels<-simLabels(n)
  brains<-simBrain(n)
  vents<-simVent(n)
  cbind(labels,brains,vents)
}


writeSimData <- function() {
  if (!dir.exists('data')){
    dir.create('data')
  }
  set.seed(1)
  write.csv(data.frame(simDataSet(500)),file.path('data','test1.csv'))
  set.seed(2)
  write.csv(data.frame(simDataSet(500)),file.path('data','test2.csv'))
}

