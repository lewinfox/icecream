
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icecream

<!-- badges: start -->

<!-- badges: end -->

Ported from [gruns/icecream](https://github.com/gruns/icecream).

## Installation

You can install from GitHub with:

``` r
devtools::install_github("lewinfox/icecream")
```

## Inspect variables

The `ic()` function prints its argument and its value. It also returns
the value of the evaluated argument.

``` r
library(icecream)

is_negative <- function(x) x < 0

ic(is_negative(1))
#> ℹ ic| `is_negative(1)`: logi FALSE
#> [1] FALSE

ic(is_negative(-1))
#> ℹ ic| `is_negative(-1)`: logi TRUE
#> [1] TRUE
```

More complex inputs are summarised to avoid cluttering the terminal.

``` r
df <- ic(iris)
#> ℹ ic| `iris`: 'data.frame':  150 obs. of  5 variables:

my_list <- ic(list(a = 1, b = 3, c = 1:100))
#> ℹ ic| `list(a = 1, b = 3, c = 1:100)`: List of 3
```

## Inspect execution

Calling `ic()` with no arguments causes it to print out the file, line
and parent function it was called from.

``` r
# demo.R
f1 <- function(x) {
  ic()
  if (x > 0) {
    f2()
  }
}

f2 <- function() {
  ic()
}
```

``` r
f1(-1)
#> ℹ ic| demo.R:2 in `f1()

f1(1)
#> ℹ ic| demo.R:2 in `f1()`
#> ℹ ic| demo.R:9 in `f2()`
```

In the case of functions that haven’t been `source()`d or loaded from a
package, the function’s environment will be displayed.

``` r
orphan_func <- function() {
  ic()
  TRUE
}

orphan_func()
#> ℹ ic| <environment: R_GlobalEnv>: `orphan_func()`
```

## Enable / disable

The `ic_enable()` and `ic_disable()` functions enable or disable the
`ic()` function. If disabled, `ic()` will return the reuslt of
evaluating its input but will not print anything.

``` r
ic_enable()

ic(mean(1:100))
#> ℹ ic| `mean(1:100)`: num 50.5
#> [1] 50.5

ic_disable()

ic(mean(1:100))
#> [1] 50.5
```

## TODO:

  - `ic.format()` and enable / disable (see
    [here](https://github.com/gruns/icecream#miscellaneous)).
