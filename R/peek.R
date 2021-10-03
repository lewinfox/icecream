#' Peek at value of expression
#'
#' This function is a proxy for calling peeking function.
#'
#' @param value The result of evaluating an expression inside the `ic()` function.
#' @param peeking_function The function used to peek at the value. Default value is set by the
#' "icecream.peeking.function" option.
#' @param max_lines Maximum number of lines printed. Default value is set by the
#' "icecream.max.lines" option.
#'
#' @details Default value of `icecream.peeking.function` is `ic_autopeek`. Suggested possible
#' alternatives are:
#'
#' * `utils::str`
#' * `print`
#' * `head`
#' * `summary`
#' * `tibble::glimpse`
#'
#' @return A string to be printed.
#'
#' @seealso [ic_autopeek()] [utils::str()] [base::print()] [utils::head()] [base::summary()]
#' [tibble::glimpse()]
#'
#' @keywords internal
ic_peek <- function(value,
                    peeking_function = getOption("icecream.peeking.function"),
                    max_lines = getOption("icecream.max.lines")) {
  output <- utils::capture.output(peeking_function(value))
  real_lines <- min(length(output), max_lines)
  if (real_lines == 1) {
    trimws(output[[1]])
  } else {
    output <- trimws(output[1:real_lines])
    paste0(c("", output), collapse = "\n")
  }
}
