---
title: "Range checking tool"
author: "Ian"
date: "9 February 2016"
output: html_document
---

# Range checking tool demo

This is a demonstrator Shiny (R) application for performing range checking on
volumetric MRI measures. It is composed of four files:

server.R
: Shiny server application.

ui.R
: Shiny UI template.

support.R
: Core functions for the server application.

simulate.R
: Used to build the test data-sets. Run separately from the Shiny application.
