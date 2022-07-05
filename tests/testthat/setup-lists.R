unnamed_list <- list(
  sample.int(70, size = 8),
  sample(letters, size = 4),
  logical()
)
partially_named_list <- setNames(unnamed_list, c("first", NA, "last"))
named_list <- setNames(unnamed_list, c("first", "2.", "last"))

long_list <- list(
  c(TRUE, TRUE, FALSE),
  sample.int(11, size = 3),
  list(a = 1, b = 3:6),
  seq_len(10),
  LETTERS[19:11],
  seq_len(4)
)
long_list_2 <- long_list[c(5, 2, 6, 1, 4, 3)]
