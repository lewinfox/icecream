#' Get descriptive one-line summary of an object
#'
#' This function is created as a modification of [utils::str()] function. It is supposed to
#' create more compacted yet informative summary about an object. It's default value of
#' "icecream.peeking.function"
#'
#' @param object The object to be summarized.
#' @param ... Other algorithms passed to methods.
#'
#' @details This is a generic function. Default method simply calls `utils::str` function.
#'
#' @return A string to be printed.
#'
#' @seealso [utils::str()] [ic_peek()]
#' @export
ic_autopeek <- function(object, ...) UseMethod("ic_autopeek")

ic_autopeek.default <- str

#' @importFrom glue glue glue_collapse single_quote
#' @importFrom purrr map2_chr map_chr map_int detect_index
#' @importFrom pillar obj_sum
ic_autopeek_list_or_data.frame <- function(object,
                                           max_summary_length = 70,
                                           ...) {
  # names of columns or their index if it does not exist
  col_name <- if (is.null(names(object))) seq_along(object) else ifelse(
                                                              is.na(names(object)),
                                                              seq_along(object),
                                                              single_quote(names(object)))

  # short type summary as in pillar package
  type_summary <- map_chr(object, obj_sum)

  # combine name of column and type summary
  col_summary <- glue("${col_name}: {type_summary}")

  # get header of the summary
  header <- ic_autopeek_header(object)

  # calculate how many columns summaries can fit into the console
  index <- detect_index(cumsum(map_int(col_summary, nchar) + 2),
                        ~ . > max_summary_length - nchar(header) - 3)

  # paste summary of all columns
  summary <- glue_collapse(
    if (index == 0) col_summary else c(col_summary[seq_len(index - 1)], "..."),
    sep = ", "
  )

  glue("{header}{summary}")
}

#' @param max_summary_length Integer. Maximum length of string summarizing the object.
#'
#' @describeIn ic_autopeek Method for list
ic_autopeek.list <- ic_autopeek_list_or_data.frame

#' @describeIn ic_autopeek Method for data.frame
ic_autopeek.data.frame <- ic_autopeek_list_or_data.frame

ic_autopeek_header <- function(object, ...) UseMethod("ic_autopeek_header")

ic_autopeek_header.default <- function(object, ...) glue("{class(object)[[1]]}: ")

ic_autopeek_header.list <- function(object, ...) glue("{class(object)[[1]]} [{length(object)}]: ")

ic_autopeek_header.data.frame <- function(object, ...) glue("{class(object)[[1]]} [{nrow(object)} x {ncol(object)}]: ")
