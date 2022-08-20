.onLoad <- function(libname, pkgname) {
  # Set package-specific options
  options(
    icecream_enabled = TRUE,
    icecream_prefix = "ic|",
    icecream_output_function = NULL,
    icecream_peeking_function = ic_autopeek,
    icecream_max_lines = NA_integer_,
    icecream_arg_to_string_function = NULL,
    icecream_always_include_context = FALSE
  )
}

.onUnload <- function(libpath) {
  # Unset package-specific options
  options(
    icecream_enabled = NULL,
    icecream_prefix = NULL,
    icecream_output_function = NULL,
    icecream_peeking_function = NULL,
    icecream_max_lines = NULL,
    icecream_arg_to_string_function = NULL,
    icecream_always_include_context = NULL
  )
}
