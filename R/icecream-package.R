#' Icecream: Never use `print()` to debug again
#'
#' Icecream provides a more user-friendly print debugging experience. Use [ic()] wherever you would
#' use `print()` and see the expression and its value easily.
#'
#' @section Options:
#' The following options can be used to control behaviour:
#'
#' * `icecream_enabled`: Boolean. If `FALSE`, calls to `ic(foo)` simply evaluate and return `foo`.
#'   No output is printed.
#' * `icecream_prefix`: This is printed at the beginning of every line. Defaults to `"ic|"`.
#' * `icecream_include.context`: Boolean. If `TRUE`, when calling `ic(foo)` the source file:line
#'   or environment will be printed along with the expression and value. This can be useful for more
#'   complicated debugging but produces a lot of output so is disabled by default. When `ic()` is
#'   called with no arguments, the context is always printed because showing the location of the
#'   call is the only reason to call `ic()` on its own.
#' * `icecream_peeking_function`: indicates the function that summarizes the object. Default value
#'   is `ic_autopeek`, which works like `utils::str` for most of the time, but gives more
#'   informative output for `lists`, `data.frames` and their subclasses in a more compact way.
#' * `icecream_max_lines` Integer. Determines maximum number of lines that the peek of an object
#'   occupies. If the value is `NA`, it selects proper value basing on the `icecream_peeking_function`.
#'   If peeking function is one of the supported by default (enumerated below), it selects the
#'   predefined value:
#'   - `ic_autopeek()`: 1
#'   - `base::print()`: 3,
#'   - `utils::str()`: 3,
#'   - `utils::head()`: 5,
#'   - `base::summary()`: 5,
#'   - `pillar::glimpse()` or `tibble::glimpse()`: 5.
#'
#'   If the function is not one of the predefined, default value of parameter `max_lines` or `max_lines`
#'   of the provided function is used (if it exists). Otherwise, the value of 1 is selected.
#'   If the value is distinct from `NA`, it overrides the default behavior. The value of an option
#'   defaults to `NA`.
#' * `icecream_output_function`: Not implemented yet. See the
#'   [configuration](https://github.com/gruns/icecream#configuration) section of the original
#'   project docs for details of what it will do.
#' * `icecream_arg_to_string_function`: Not implemented yet. See the
#'   [configuration](https://github.com/gruns/icecream#configuration) section of the original
#'   project docs for details of what it will do.
#'
#' @docType package
#' @name icecream
#' @keywords internal
NULL
