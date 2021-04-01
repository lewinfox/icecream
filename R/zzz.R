.onLoad <- function(libname, pkgname) {
  options(
    icecream.enabled = TRUE,
    icecream.prefix = "ic|",
    icecream.output.function = NULL,
    icecream.arg.to.string.function = NULL,
    icecream.include.context = FALSE
  )
}

.onUnload <- function(libpath) {
  options(
    icecream.enabled = NULL,
    icecream.prefix = NULL,
    icecream.output.function = NULL,
    icecream.arg.to.string.function = NULL,
    icecream.include.context = NULL
  )
}
