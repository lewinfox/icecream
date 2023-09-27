#' Get descriptive one-line summary of an object
#'
#' This function is created as a modification of [utils::str()] function. It is supposed to
#' create more compacted yet informative summary about an object. It's default value of
#' "icecream.peeking.function"
#'
#' @param object The object to be summarized.
#' @param ... Other arguments passed to methods.
#'
#' @details This is a generic function. Default method simply calls `utils::str` function.
#'
#' @return The function is mainly used for its side effects -- outputting to the terminal.
#' However, it also returns an invisible string of the printed summary.
#'
#' @seealso [utils::str()] [ic_peek()]
ic_autopeek <- function(object, ...) {
  UseMethod("ic_autopeek")
}

#' @export
ic_autopeek.default <- function(object, ...) {
  utils::str(object, ...)
}

#' @param max_summary_length Integer. Maximum length of string summarizing the object. By default
#'   this is set to the current terminal width.
#'
#' @describeIn ic_autopeek Method for list
#' @keywords internal
#'
#' @export
ic_autopeek.list <- function(object, max_summary_length = cli::console_width(), ...) {
  # names of columns or their index if it does not exist
  col_name <- if (is.null(names(object))) {
    seq_along(object)
  } else {
    ifelse(
      is.na(names(object)),
      seq_along(object),
      glue::single_quote(names(object))
    )
  }

  # short type summary as in pillar package
  type_summary <- purrr::map_chr(object, pillar::obj_sum)

  # combine name of column and type summary
  col_summary <- glue::glue("${col_name}: {type_summary}")

  # get header of the summary
  header <- ic_autopeek_header(object)

  # calculate how many columns summaries can fit into the console
  index <- purrr::detect_index(
    cumsum(nchar(col_summary) + 2 + nchar(header)),
    ~ . > max_summary_length
  )

  # paste summary of all columns
  summary <- glue::glue_collapse(
    if (index == 0) col_summary else c(col_summary[seq_len(index - 1)], "..."),
    sep = ", "
  )

  ret <- paste0(header, summary)
  cat(ret)
  invisible(ret)
}

#' @describeIn ic_autopeek Method for data.frame
#' @export
ic_autopeek.data.frame <- ic_autopeek.list

#' Get a header of the object peeked at
#'
#' @param object The object peeked at.
#' @param ... Other arguments passed to methods.
#'
#' @details This function is used by `ic_autopeek` to get a header of the summary of a object.
#' It should return object's top-level class name and its dimension.
#'
#' @keywords internal
ic_autopeek_header <- function(object, ...) {
  UseMethod("ic_autopeek_header")
}

#' @export
ic_autopeek_header.default <- function(object, ...) {
  glue::glue("{class(object)[[1]]}: ")
}

#' @export
ic_autopeek_header.list <- function(object, ...) {
  glue::glue("{class(object)[[1]]} [{length(object)}]: ")
}

#' @export
ic_autopeek_header.data.frame <- function(object, ...) {
  glue::glue("{class(object)[[1]]} [{nrow(object)} x {ncol(object)}]: ")
}
