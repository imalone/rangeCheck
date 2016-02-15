---
title: "Range checking tool"
author: "Ian"
date: "15 February 2016"
output: html_document
---

# Range checking tool demo

This is a demonstrator Shiny (R) application for performing range checking on volumetric MRI measures. For instructions see the in-application help or bsModalHelp function in rangeCheck/ui.R. In brief, uploaded datasets  from volumetric brain measurements (or a default) are processed to select observation tails and a random selection of inliers for manual checking to assure data quality. For more information on why this is useful, see the presentation http://imalone.github.io/rangeCheck/.

**N.B. ui.R and server.R located in the rangeCheck/ directory. deployApp() sends all files in directory and the presentation files shouldn't be included.**

index.Rmd, index.md, index.html
: slidify presentation, shared to gh-pages branch

assets/
: Files for slidify presentation (used when building)

rangeCheck/
: Contains files for the rangeCheck application

rangeCheck/server.R
: Shiny server application.

rangeCheck/ui.R
: Shiny UI template.

rangeCheck/support.R
: Core functions for the server application.

rangeCheck/debounce.R
: from https://gist.github.com/jcheng5/6141ea7066e62cafb31c

rangeCheck/simulate.R
: Used to build the test data-sets. Run separately from the Shiny application.

rangeCheck/data
: Contains testing data for upload (both valid and invalid)
