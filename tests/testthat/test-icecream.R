test_that("`ic.enable()` and `ic.disable()` work", {
  old.opt <- getOption("icecream.enabled")

  options(icecream.enabled = TRUE)

  expect_message(ic(1), regexp = "i ic| `1`: num 1")

  ic.disable()

  expect_message(ic(1), NA)

  ic.enable()

  expect_message(ic(1), regexp = "i ic| `1`: num 1")

  options(icecream.enabled = old.opt)
})

