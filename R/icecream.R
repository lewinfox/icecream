ic <- function(x) {
  # If `x` is missing we want to print the filename, line number and parent function
  if (missing(x)) {
    caller_fn <- try(sys.calls()[[sys.nframe() - 1]], silent = TRUE)
    caller_ref <- try(sys.function(-1), silent = TRUE)
    if (inherits(caller_fn, "try-error")) {
      rlang::abort("`ic()` can only be called with no arguments from within another function", "icecream-error")
    }
    srcloc <- list(
      file = getSrcFilename(caller_ref),
      line = getSrcLocation(caller_ref),
      fun = deparse(caller_fn[[1]])
    )
    prefix <- getOption("icecream.alert.prefix", "ic|")
    cli::cli_alert_info("{prefix} {.path {srcloc$file}:{srcloc$line}} in {.fn {srcloc$fun}}")
    return(invisible())
  }
  # Otherwise capture the expression, evaluate and print.
  q <- rlang::enquo(x)
  ex <- deparse(rlang::quo_get_expr(q))
  res <- rlang::eval_tidy(q)
  prefix <- getOption("icecream.alert.prefix", "ic|")
  str_res <- trimws(capture.output(str(res)))
  if (length(str_res) > 1) {
    str_res <- str_res[[1L]]
  }
  cli::cli_alert_info("{prefix} {.var {ex}}: {str_res}")
  res
}
