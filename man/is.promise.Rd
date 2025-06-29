% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/promise.R
\name{is.promise}
\alias{is.promise}
\alias{is.promising}
\alias{as.promise}
\title{Coerce to a promise}
\usage{
is.promise(x)

is.promising(x)

as.promise(x)
}
\arguments{
\item{x}{An R object to test or coerce.}
}
\value{
\code{as.promise} returns a promise object, or throws an error if the
object cannot be converted.

\code{is.promise} returns \code{TRUE} if the given value is a promise object, and
\code{FALSE} otherwise.

\code{is.promising} returns \code{TRUE} if the given value is a promise object or
if it can be converted to a promise object using \code{as.promise}, and \code{FALSE}
otherwise.
}
\description{
Use \code{is.promise} to determine whether an R object is a promise. Use
\code{as.promise} (an S3 generic method) to attempt to coerce an R object to a
promise, and \code{is.promising} (another S3 generic method) to test whether
\code{as.promise} is supported. \link[mirai:mirai]{mirai::mirai} objects have an \code{as.promise} method
defined in the mirai package, and this package provides one for converting
\link[future:Future-class]{future::Future} objects into promises.
}
