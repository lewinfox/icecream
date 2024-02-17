# icecream 0.1.1

* First release.


# icecream 0.2.0

* Large or complex objects like data frames and lists are now printed in a more user-friendly way 
  (@DominikRafacz and @ErdaradunGaztea)
* New context managers `with_ic_enable()` and `with_ic_disable()` introduced (#6, @Ben-Stiles).
* `ic()` output is now dynamically truncated to the width of the terminal.
* `ic()` will now work properly with `rlang` 1.0 (#8, @lionel-)

# icecream 0.2.1

* Small change to bring package-level documentation in line with current roxygen standards
  [https://github.com/r-lib/roxygen2/issues/1491]

# icecream 0.2.2

* Allow `ic()` to handle inputs that aren't valid `glue()` code, e.g. `ic("{")` (#26)
