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

test_that("`ic()` returns input invisibly", {
  suppressMessages({
    expect_invisible(ic(mean(1:100)))
    expect_invisible(ic(iris), iris)
    expect_invisible(ic(TRUE), TRUE)
    expect_invisible(ic(list(a = 1, b = 2)))
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
})
