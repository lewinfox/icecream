#' Functions re-exported from rlang
#'
#' @name rlang-reexports
NULL

#' @describeIn rlang-reexports Return source location from a srcref. If no srcref is found, return
#'   `""`.
src_loc <- function(srcref, dir = getwd()) {
  if (is.null(srcref)) {
    return("")
  }
  srcfile <- attr(srcref, "srcfile")
  if (is.null(srcfile)) {
    return("")
  }
  file <- srcfile$filename
  if (identical(file, "") || identical(file, "<text>")) {
    return("")
  }
  if (!file.exists(file)) {
    return("")
  }
  line <- srcref[[1]]
  column <- srcref[[5]] - 1L
  paste0(relish(file, dir = dir), ":", line, ":", column)
}

#' @describeIn rlang-reexports Tidy file paths
relish <- function(x, dir = getwd()) {
  if (substr(dir, nchar(dir), nchar(dir)) != "/") {
    dir <- paste0(dir, "/")
  }
  gsub(dir, "", x, fixed = TRUE)
}
