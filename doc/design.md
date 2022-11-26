# signals

* `create_signal` returns reactive state getter and setter
* signal will be identified by the getter


# range update

Signal returns,

* prev range
* range diff

Effect updates,

* IF the prev range is before the current line,
    * update the *start_row*, *end_row*
* IF the prev range is in the same line as start_row and end_row
    * update the *start_row*, *start_col*, *end_row*, *end_col*
* IF the prev range is in the same line as start_row
    * update the *start_row*, *start_col*, *end_row*

* IF the prev range is within,
    * update the *end_row*, *end_col*
* IF the prev range is after,
    * update nothing
