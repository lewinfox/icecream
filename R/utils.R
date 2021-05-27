#' Functions re-exported from rlang
#'
#' These are used to extract and format source references. As they are not part of the public rlang
#' API they are reimplemented here.
#'
#' @param srcref A `srcref` object
#' @param dir Directory path
#' @param x File path
#'
#' @name rlang-reexports
#' @keywords internal
#'
#' @return Character vector containing either a source location (for `src_loc()`) or a path (for
#'   `relish()`).
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

#' @describeIn rlang-reexports Tidy file paths by removing instances of `dir` from `x`. Ensures that
#'   we get a relative path for `x`.
relish <- function(x, dir = getwd()) {
  if (substr(dir, nchar(dir), nchar(dir)) != "/") {
    dir <- paste0(dir, "/")
  }
  gsub(dir, "", x, fixed = TRUE)
}
