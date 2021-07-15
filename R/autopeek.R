#' Get descriptive one-line summary of an object
#'
#' This function is created as a modification of [utils::str()] function. It is supposed to
#' create more compacted yet informative summary about an object. It's default value of
#' "icecream.peeking.function"
#'
#' @param x The object to be summarized.
#' @param ... Other algorithms passed to methods.
#'
#' @details This is a generic function. Default method simply calls `utils::str` function.
#'
#' @return A string to be printed.
#'
#' @seealso [utils::str()] [ic_peek()]
#' @export
ic_autopeek <- function(x, ...) UseMethod("ic_autopeek")

#' @export
ic_autopeek.default <- str

#' @importFrom glue glue
#' @importFrom purrr map2_chr map_chr map_int detect_index
#' @importFrom pillar obj_sum
ic_autopeek_list_or_data.frame <- function(x,
                                           max_summary_length = 70,
                                           ...) {
  # names of columns or their index if it does not exist
  col_name <- if (is.null(names(x))) seq_along(x) else ifelse(is.na(names(x)),
                                                              seq_along(x),
                                                              glue("'{names(x)}'"))

  # short type summary as in pillar package
  type_summary <- map_chr(x, obj_sum)

  # combine name of column and type summary
  col_summary <- map2_chr(col_name, type_summary, function(name, sum) glue("${name}: {sum}"))

  # get header of the summary
  header <- ic_autopeek_header(x)

  # calculate how many columns summaries can fit into the console
  index <- detect_index(cumsum(map_int(col_summary, nchar) + 2),
                        ~ . > max_summary_length - nchar(header))

  # paste summary of all columns
  summary <- paste0(if (index == 0) col_summary else c(col_summary[1:(index - 1)], "..."),
                    collapse = ", ")

  glue("{header}{summary}")
}

#' @param max_summary_length Integer. Maximum length of string summarizing the
#'
#' @describeIn ic_autopeek Method for list
ic_autopeek.list <- ic_autopeek_list_or_data.frame

#' @param max_summary_length Integer. Maximum length of string summarizing the
#'
#' @describeIn ic_autopeek Method for data.frame
ic_autopeek.data.frame <- ic_autopeek_list_or_data.frame

ic_autopeek_header <- function(x, ...) UseMethod("ic_autopeek_header")

ic_autopeek_header.default <- function(x, ...) glue("{class(x)[[1]]}: ")

ic_autopeek_header.list <- function(x, ...) glue("{class(x)[[1]]} [{length(x)}]: ")

ic_autopeek_header.data.frame <- function(x, ...) glue("{class(x)[[1]]} [{nrow(x)} x {ncol(x)}]: ")
