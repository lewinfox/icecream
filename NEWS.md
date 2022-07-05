# icecream 0.1.1

* First release.


# icecream 0.2.0

* Large or complex objects like data frames and lists are now printed in a more user-friendly way 
  (@DominikRafacz and @ErdaradunGaztea)
* New context managers `with_ic_enable()` and `with_ic_disable()` introduced (#6, @Ben-Stiles).
* `ic()` output is now dynamically truncated to the width of the terminal.
* `ic()` will now work properly with `rlang` 1.0 (#8, @lionel-)
