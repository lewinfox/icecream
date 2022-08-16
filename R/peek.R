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
                    peeking_function,
                    max_lines) {
  # If max_lines in non-NA then it was provided explicitly and this setting overrides the defaults
  # Otherwise, we need to find the proper value of max_lines basing on peeking_function
  if (is.na(max_lines)) max_lines <- ic_get_default_max_lines(peeking_function)

  # We don't want to output it directly to terminal, as it still needs to get trimmed
  output <- utils::capture.output(peeking_function(value))
  real_lines <- min(length(output), max_lines)
  if (real_lines == 1) {
    trimws(output[[1]])
  } else {
    output <- trimws(output[1:real_lines])
    paste0(c("", output), collapse = "\n")
  }
}

#' List of predefined peeking functions
#'
#' Peeking functions handled by default by the `ic_peek()`
#'
#' @format A named list of 6 elements. Elements are functions that take arbitrary R object as
#' an input and print to the console or return string as an output. Names of the elements
#' are names of the function without the package name.
#'
#' @keywords internal
ic_predefined_peeking_functions <- list(
  "ic_autopeek" = ic_autopeek,
  "print" = base::print,
  "str" = utils::str,
  "head" = utils::head,
  "summary" = base::summary,
  "glimpse" = pillar::glimpse
)

#' Values of max_lines for predefined peeking functions
#'
#' Default max_lines values for peeking functions handled by default by the `ic_peek()`
#'
#' @format A named numeric vector of 6 elements. Elements are the max_line values for
#' predefined peeking functions. Names correspond to names of [ic_predefined_peeking_functions]
#'
#' @keywords internal
ic_predefined_max_lines <- c(
  "ic_autopeek" = 1,
  "print" = 3,
  "str" = 3,
  "head" = 5,
  "summary" = 5,
  "glimpse" = 5
)

#' Get default value of max_lines parameter for given function
#'
#' @inheritParams ic_peek
#'
#' @return An integer value bigger than 0. If `peeking_function` is one of those handled by default,
#' a value of corresponding predefined value. Otherwise, if function has a named parameter "max_lines"
#' or "max.lines" with default value, the default value. Otherwise, a value of 1.
#'
#' @keywords internal
ic_get_default_max_lines <- function(peeking_function) {
  # Checking if provided peeking function is within list of suggested peekers
  match <- purrr::map_lgl(ic_predefined_peeking_functions, ~ identical(.x, peeking_function))

  # If a match is found, take the corresponding value
  # Don't checking if there is more than one match, because of identity
  if (any(match)) {
    return(ic_predefined_max_lines[match])
  } else {
    # Checking for explicitly provided formal default in the custom peeking function
    formals <- rlang::fn_fmls(peeking_function)
    arg <- names(formals) %in% c("max_lines", "max.lines")

    # Checking if there is exactly one match which has a default value
    if (sum(arg) == 1) {
      arg <- formals[[which(arg)]]
      if (as.character(arg) != "") return(arg)
    }

    return(1) # If everything fails, fallback to 1
  }
}
