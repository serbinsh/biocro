\name{plot.MCMCc4photo}
\alias{plot.MCMCc4photo}
\title{Plotting function for MCMCc4photo objects}
\usage{
  plot.MCMCc4photo(x, x2 = NULL, x3 = NULL,
    plot.kind = c("trace", "density"), type = c("l", "p"),
    burnin = 1, cols = c("blue", "green", "purple"),
    prior = FALSE, pcol = "black", ...)
}
\arguments{
  \item{x}{\code{\link{MCMCc4photo}} object.}

  \item{x2}{optional additional \code{\link{MCMCc4photo}}
  object.}

  \item{x3}{optional additional \code{\link{MCMCc4photo}}
  object.}

  \item{plot.kind}{'trace' plots the iteration history and
  'density' plots the kernel density.}

  \item{type}{only the options for line and point are
  offered.}

  \item{burnin}{this will remove part of the chain that can
  be considered burn-in period.  The plots will no include
  this part.}

  \item{cols}{Argument to pass colors to the line or points
  being plotted.}

  \item{prior}{Whether to plot the prior density. It only
  works when x2 = NULL and x3 = NULL. Default is FALSE.}

  \item{pcol}{Color used for plotting the prior density.}

  \item{\dots}{Optional arguments.}
}
\description{
  By default it prints the trace of the four parameters
  being estimated by the \code{\link{MCMCc4photo}}
  function. As an option the density can be plotted.
}
\details{
  This function uses internally
  \code{\link[lattice]{xyplot}},
  \code{\link[lattice]{densityplot}} and
  \code{\link[lattice]{panel.mathdensity}} both in the
  'lattice' package.
}
\seealso{
  \code{\link{MCMCc4photo}}
}
\keyword{hplot}

