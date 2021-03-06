% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/partition.ITR.R
\name{partition.ITR}
\alias{partition.ITR}
\title{Generates partition summary based on itr value. Used inside of the grow.ITR function.}
\usage{
partition.ITR(dat, test = NULL, name = "0", min.ndsz = 20, n0 = 5,
  split.var, ctg = NULL, max.depth = 15, mtry = length(split.var))
}
\arguments{
\item{dat}{data set from which the partition is to be made.  Must contain outcome, binary 
treatment indicator, columns of splitting covariates, and column of probability of being
in treatment group.}

\item{min.ndsz}{minimum number of observations required to call a node terminal. Defaults to 20.}

\item{n0}{minimum number of treatment/control observations needed in a split to call a node terminal. Defaults to 5.}

\item{split.var}{columns of potential spliting variables. Required input.}

\item{ctg}{identifies the categorical input columns.  Defaults to NULL.  Not available yet.}

\item{max.depth}{controls the maximum depth of the tree. Defaults to 15.}

\item{mtry}{sets the number of randomly selected splitting variables to be included. Defaults to number of splitting variables.}
}
\value{
partition information based on itr value
}
\description{
Generates partition summary based on itr value. Used inside of the grow.ITR function.
}

