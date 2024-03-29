\name{print.MCMCEc4photo}
\alias{print.MCMCEc4photo}
\title{Print an MCMCEc4photo object}
\usage{
  print.MCMCEc4photo(x, level = 0.95, ...)
}
\arguments{
  \item{x}{\code{\link{MCMCEc4photo}} object}

  \item{level}{specified \code{level} for the Highest
  Posterior Density region.}

  \item{\dots}{Optional arguments}
}
\description{
  This functions doesn't just print the object components,
  but it also computes quantiles according to the
  \code{level} argument below and a correlation matrix as
  well as a summary for each parameter.
}
\details{
  The Highest Posterior Density region is calculated using
  the \code{\link{quantile}} function.  The correlation
  matrix is computed using the \code{\link{cor}} function.
  The summaries for each parameter are computed using the
  \code{\link{summary}} function.
}
\seealso{
  \code{\link{MCMCEc4photo}}
}
\keyword{optimize}

