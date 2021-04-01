.onLoad <- function(libname, pkgname) {
  options(icecream.enabled = TRUE, icecream.alert.prefix = "ic|")
}

.onUnload <- function(libpath) {
  options(icecream.enabled = NULL, icecream.alert.prefix = NULL)
}
