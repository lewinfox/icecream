
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icecream <img src="man/figures/logo.svg" align="right" width="120" />

<!-- badges: start -->

[![](https://cranlogs.r-pkg.org/badges/icecream)](https://cran.r-project.org/package=icecream)
[![R-CMD-check](https://github.com/lewinfox/icecream/workflows/R-CMD-check/badge.svg)](https://github.com/lewinfox/icecream/actions)
<!-- badges: end -->

icecream is designed to make print debugging easier. It allows you to
print out an expression, its value and (optionally) which function and
file the call originated in.

This is an R port of
[gruns/icecream](https://github.com/gruns/icecream). All credit for the
idea belongs to [Ansgar Grunseid](https://github.com/gruns).

## Installation

Install from CRAN with:

``` r
install.packages("icecream")
```

Or you can install the development version from GitHub with:

``` r
devtools::install_github("lewinfox/icecream")
```

## Inspect variables

The `ic()` function prints its argument and its value. It also returns
the value of the evaluated argument, meaning that it is effectively
transparent in code - just wrap an expression in `ic()` to get debugging
output.

``` r
library(icecream)

is_negative <- function(x) x < 0

ic(is_negative(1))
#> ℹ ic| `is_negative(1)`: logi FALSE

ic(is_negative(-1))
#> ℹ ic| `is_negative(-1)`: logi TRUE
```

You’re more likely to want to do this within a function:

``` r
some_function <- function(x) {
  intermediate_value <- x * 10
  answer <- ic(intermediate_value / 2)
  return(answer)
}

some_function(1)
#> ℹ ic| `intermediate_value / 2`: num 5
#> [1] 5

some_function(10)
#> ℹ ic| `intermediate_value / 2`: num 50
#> [1] 50
```

More complex inputs like lists and data frames are summarised to avoid
cluttering the terminal.

``` r
df <- ic(iris)
#> ℹ ic| `iris`: data.frame [150 x 5]: $'Sepal.Length': dbl [150], ...

my_list <- ic(list(a = 1, b = 3, c = 1:100))
#> ℹ ic| `list(a = 1, b = 3, c = 1:100)`: list [3]: $'a': dbl [1], $'b': dbl [1], $'c': int [100]
```

## Inspect execution

Calling `ic()` with no arguments causes it to print out the file, line
and parent function it was called from.

In this example we have a file `demo.R` that contains two functions.
We’ve inserted `ic()` calls at strategic points so we can track what’s
being executed.

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

f3 <- function(x) {
  ic(x)
}
```

``` r
source("demo.R")

f1(-1)
#> ℹ ic| `global::f1()` in demo.R:3:2

f1(1)
#> ℹ ic| `global::f1()` in demo.R:3:2
#> ℹ ic| `global::f2()` in demo.R:10:2
```

In the case of functions that haven’t been `source()`d or loaded from a
package there is no source code to refer to. In these cases the
function’s environment will be displayed.

``` r
orphan_func <- function() {
  ic()
  TRUE
}

orphan_func()
#> ℹ ic| `global::orphan_func()` in <env: global>
#> [1] TRUE

e <- new.env()
attr(e, "name") <- "icecream_van"
environment(orphan_func) <- e

orphan_func()
#> ℹ ic| `orphan_func()` in <env: icecream_van>
#> [1] TRUE
```

## Enable / disable

The `ic_enable()` and `ic_disable()` functions enable or disable the
`ic()` function. If disabled, `ic()` will return the result of
evaluating its input but will not print anything.

``` r
ic_enable() # This is TRUE by default

ic(mean(1:100))
#> ℹ ic| `mean(1:100)`: num 50.5

ic_disable()

ic(mean(1:100))
#> [1] 50.5
```

Convenience functions `with_ic_enable()` and `with_ic_disable()` are
also provided.

``` r
ic_enable()

with_ic_disable(ic(mean(1:100)))
#> [1] 50.5

ic_disable()

with_ic_enable(ic(mean(1:100)))
#> ℹ ic| `mean(1:100)`: num 50.5
```

## Options

The following options can be used to control behaviour:

### `icecream.enabled`

Boolean. If `FALSE`, calls to `ic(foo)` simply evaluate and return
`foo`. No output is printed. This option can be set directly or with the
`ic_enable()` and `ic_disable()` functions.

### `icecream.prefix`

This is printed at the beginning of every line. Defaults to `"ic|"`.

``` r
ic(mean(1:5))
#> ℹ ic| `mean(1:5)`: num 3

options(icecream.prefix = "DEBUG:")
ic(mean(1:5))
#> ℹ DEBUG: `mean(1:5)`: num 3

options(icecream.prefix = "\U1F366")
ic(mean(1:5))
#> ℹ 🍦 `mean(1:5)`: num 3
```

### `icecream.always.include.context`

Boolean. If `TRUE`, when calling `ic(foo)` the source file and line will
be printed along with the expression and value. If no `srcref()` is
available the function’s environment will be displayed instead. This can
be useful for more complicated debugging but produces a lot of output so
is disabled by default.

``` r
f3(1)
#> ℹ ic| `x`: num 1

options(icecream.always.include.context = TRUE)

f3(1)
#> ℹ ic| `global::f3()` in demo.R:14:2 | `x`: num 1
```

When `ic()` is called with no arguments, the context is always printed
because showing the location of the call is the only reason to call
`ic()` on its own.

### `icecream.peeking.function` and `icecream.max.lines`

These two options control how the result of evaluation of an expression
is printed. `icecream.peeking.function` indicates the function that
summarizes the object. Default value is `ic_autopeek`, which works like
`utils::str` for most of the time, but gives more informative output for
`lists`, `data.frames` and their subclasses in a more compact way.
`icecream.max.lines` determines maximum number of lines that the peek of
an object occupies; defaults to 1.

For more complex data you may want to use e.g. `head` function and 5
lines.

``` r
data(iris)

ic(iris) # we would like to see header of the data
#> ℹ ic| `iris`: data.frame [150 x 5]: $'Sepal.Length': dbl [150], ...

options(icecream.peeking.function = head,
        icecream.max.lines = 5)

ic(iris)
#> ℹ ic| `iris`: 
#> Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
```

Note that if `icecream.max.lines` is greater than 1 and summary of an
object is longer than 1, the alert occupies one line more due to the
header.

### `icecream.output.function`, `icecream.arg.to.string.function`

Not implemented yet. See the
[configuration](https://github.com/gruns/icecream#configuration) section
of the original project docs for details of what they will do.

## TODO:

-   Implement `ic.format()` (see
    [here](https://github.com/gruns/icecream#miscellaneous)).
-   Implement `ic.output.function`. At the moment it uses
    `cli::cli_alert_info()`
-   Implement `ic.arg.to.string.function`
