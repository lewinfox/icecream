library(checkmate)
library(glue)

test_that("`ic_autopeek()` has specific format for lists", {
  purrr::walk(
    all_lists,
    ~ expect_string(
      ic_autopeek(.x),
      pattern = "^list \\[\\d+\\]: (?:\\$[^:]+: \\S+ \\[\\d+\\](?:, )?)+(?:\\.{3})?$"
    )
  )
})

# header tests ----
test_that("`ic_autopeek()` prints correct list length", {
  expect_string(
    ic_autopeek(unnamed_list),
    pattern = glue("^list \\[{length(unnamed_list)}\\]:")
  )
})

# element names tests ----
test_that("`ic_autopeek()` prints indices for unnamed lists", {
  #> list [3]: $1: int [8], $2: chr [4], $3: lgl [0]
  expect_string(
    ic_autopeek(unnamed_list),
    pattern = glue_collapse(glue("\\${seq_along(unnamed_list)}:.*"))
  )
})

test_that("`ic_autopeek()` prints names for named lists", {
  #> list [3]: $'first': int [8], $'2.': chr [4], $'last': lgl [0]
  expect_string(
    ic_autopeek(named_list),
    pattern = glue_collapse(glue("\\$'{names(named_list)}':.*"))
  )
})

test_that("`ic_autopeek()` mixes names and indices for partially named lists", {
  #> list [3]: $'first': int [8], $2: chr [4], $'last': lgl [0]
  list_names <- names(partially_named_list)
  list_names[!is.na(list_names)] <- glue("'{list_names[!is.na(list_names)]}'")
  list_names[is.na(list_names)] <- which(is.na(list_names))
  expect_string(
    ic_autopeek(partially_named_list),
    pattern = glue_collapse(glue("\\${list_names}:.*"))
  )
})

# element description tests ----
test_that("`ic_autopeek()` contains vector abbreviations", {
  purrr::walk(
    all_lists,
    ~ expect_string(
      ic_autopeek(.x),
      pattern = glue_collapse(glue("{purrr::map_chr(.x, vctrs::vec_ptype_abbr)}.*"))
    )
  )
})

test_that("`ic_autopeek()` displays element lengths", {
  purrr::walk(
    all_lists,
    ~ expect_string(
      ic_autopeek(.x),
      pattern = glue_collapse(glue("\\S+ \\[{lengths(.x)}\\].*"))
    )
  )
})
