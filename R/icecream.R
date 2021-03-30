ic <- function(x) {
  # If `x` is missing we want to print the filename, line number and parent function
  if (missing(x)) {
    caller_fn <- try(sys.calls()[[sys.nframe() - 1]], silent = TRUE)
    caller_ref <- try(sys.function(-1), silent = TRUE)
    if (inherits(caller_fn, "try-error")) {
      rlang::abort("`ic()` can only be called with no arguments from within another function")
    }
    srcloc <- list(
      file = getSrcFilename(caller_ref),
      line = getSrcLocation(caller_ref),
      fun = deparse(caller_fn[[1]])
    )
    cli::cli_alert_info("ic| {.path {srcloc$file}:{srcloc$line}} in {.fn {srcloc$fun}}")
    return(invisible())
  }
  # Otherwise capture the expression, evaluate and print.
  q <- rlang::enquo(x)
  ex <- rlang::quo_get_expr(q)
  res <- rlang::eval_tidy(q)
  msg <- glue::glue("ic| {deparse(ex)}: {res}")
  cli::cli_alert_info(msg)
  res
}
