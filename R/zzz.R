.onLoad <- function(libname, pkgname) {
  # Set package-specific options
  options(
    icecream.enabled = TRUE,
    icecream.prefix = "ic|",
    icecream.output.function = NULL,
    icecream.peeking.function = ic_autopeek,
    icecream.max.lines = 1,
    icecream.arg.to.string.function = NULL,
    icecream.always.include.context = FALSE
  )
}

.onUnload <- function(libpath) {
  # Unset package-specific options
  options(
    icecream.enabled = NULL,
    icecream.prefix = NULL,
    icecream.output.function = NULL,
    icecream.peeking.function = NULL,
    icecream.max.lines = NULL,
    icecream.arg.to.string.function = NULL,
    icecream.always.include.context = NULL
  )
}
