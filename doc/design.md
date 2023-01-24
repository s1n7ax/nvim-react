# signals

- `create_signal` returns reactive state getter and setter
- signal will be identified by the getter

## range update

Signal returns,

- prev range
- range diff

Effect updates,

- IF the prev range is before the current line,
  - update the _start_row_, _end_row_
- IF the prev range is in the same line as start_row and end_row
  - update the _start_row_, _start_col_, _end_row_, _end_col_
- IF the prev range is in the same line as start_row

  - update the _start_row_, _start_col_, _end_row_

- IF the prev range is within,
  - update the _end_row_, _end_col_
- IF the prev range is after,
  - update nothing
