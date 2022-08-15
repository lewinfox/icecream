library(withr)

# TODO: Testing things like correct environment detection are tricky because of the way testthat
#       works. Need to add some more checks for correct identification of source file and env.

test_that("`ic_enable()` and `ic_disable()` work", {
  with_options(list(icecream.enabled = TRUE), {
    expect_message(ic(1))
    ic_disable()
    expect_message(ic(1), NA)
    ic_enable()
    expect_message(ic(1))
  })
})

test_that("`with_ic_enable()` and `with_ic_disable()` work", {
  with_options(list(icecream.enabled = TRUE), {
    expect_message(ic(1))
    expect_message(with_ic_disable(ic(1)), NA)
    ic_disable()
    expect_message(with_ic_enable(ic(1)))
  })
})

test_that("disabled `ic()` returns correct values", {
  with_ic_disable({
    expect_equal(ic(42), 42)
    expect_equal(ic(23, 45), list(23, 45))
  })
})

test_that("`ic()` prints summaries for complex objects", {
  expect_message(ic(iris), regexp = "data\\.frame")
  expect_message(ic(complex(100)), regexp = "cplx \\[1:100\\] 0\\+0i 0\\+0i 0\\+0i")
  expect_message(ic(integer(100)), regexp = "int \\[1:100\\] 0 0 0 0 0 0 0 0 0 0")
})

test_that("`ic()` returns inputs unchanged", {
  suppressMessages({
    expect_equal(ic(mean(1:100)), mean(1:100))
    expect_equal(ic(iris), iris)
    expect_equal(ic(TRUE), TRUE)
    expect_equal(ic(list(a = 1, b = 2)), list(a = 1, b = 2))
  })
})

test_that("`ic()` with multiple expressions returns a list of their values", {
  suppressMessages({
    expect_equal(ic(2 + 3, sum(1:5)), list(2 + 3, sum(1:5)))
    expect_equal(ic(letters, exp(12), c(4, 5)), list(letters, exp(12), c(4, 5)))
  })
})

test_that("`ic()` returns input invisibly", {
  suppressMessages({
    expect_invisible(ic(mean(1:100)))
    expect_invisible(ic(iris), iris)
    expect_invisible(ic(TRUE), TRUE)
    expect_invisible(ic(list(a = 1, b = 2)))
    expect_invisible(ic(1, 2))
  })
})

test_that("`ic()` without arguments returns nothing invisibly", {
  suppressMessages({
    expect_null(ic())
    expect_invisible(ic())
  })
})

test_that("setting prefixes works", {
  with_options(list(icecream.prefix = "HELLO"), {
    expect_message(ic(1), regexp = "HELLO")
  })

  suppressMessages({
    expect_message(ic(1, prefix = "IT'S ME"), regexp = "IT'S ME")
  })
})

test_that("changing printing function works", {
  foo <- function(x) cat(min(x), "-", max(x))

  with_options(list(icecream.peeking.function = print), {
    expect_message(ic(1:5), regexp = "\\[1\\] 1 2 3 4 5")
  })

  with_options(list(icecream.peeking.function = foo), {
    expect_message(ic(0:100), regexp = "0 - 100")
  })

  suppressMessages({
    expect_message(ic(1:5, peeking.function = print), regexp = "\\[1\\] 1 2 3 4 5")
    expect_message(ic(0:100, peeking.function = foo), regexp = "0 - 100")
  })
})

expect_max_lines <- function(expr, max_lines) {
  msgs <- capture_messages(expr)
  num_lines <- stringi::stri_count_fixed(msgs, "\n")
  expect(num_lines <= max_lines, failure_message = "Number of lines printed is higher than expected!")
}

test_that("changing max lines works", {
  expect_max_lines(ic(iris), 1)
  expect_max_lines(ic(iris, peeking.function = print), 4)
  expect_max_lines(ic(iris, peeking.function = head), 6)
  expect_max_lines(ic(iris, peeking.function = print, max.lines = 10), 11)
  with_options(list(icecream.peeking.function = print, icecream.max.lines = 10), {
    expect_max_lines(ic(iris), 11)
  })
})

test_that("always including context works", {
  with_options(list(icecream.always.include.context = TRUE), {
    expect_message(ic(42), regexp = "<.*> \\| `42`: num 42")
  })

  suppressMessages({
    expect_message(ic(42, always.include.context = TRUE), regexp = "<.*> \\| `42`: num 42")
  })
})


test_that("function environment is correctly identified", {
  f <- function() {
    ic()
    1
  }

  # Remove the srcref to ensure we fall back on the environment
  f <- utils::removeSource(f)

  # Make sure the env name shows up in the output
  environment(f) <- .GlobalEnv
  expect_message(f(), regexp = "env: global")

  e <- new.env()
  attr(e, "name") <- "icecream_van"
  environment(f) <- e
  expect_message(f(), regexp = "env: icecream_van")
})


test_that("source file is correctly identified", {
  temp <- tempfile(pattern = "my_name_is_inigo_montoya", fileext = ".R")
  cat("f <- function() {ic(); 1}", file = temp)
  on.exit(unlink(temp))
  source(temp, keep.source = TRUE)
  expect_message(f(), regexp = "my_name_is_inigo_montoya")
})
