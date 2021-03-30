.onLoad <- function(libname, pkgname) {
  options(icecream.alert.prefix = "ic|")
}

.onUnload <- function(libpath) {
  options(icecream.alert.prefix = NULL)
}
