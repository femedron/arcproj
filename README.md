
# NASM project

**Task**:
- Read N lines from stdin until EOF appears (maximum 10,000 lines). Lines are separated by a single byte - 0x0A. Each line is a pair "<key> <value>" (separated by a space), where the key is a textual identifier with a maximum of 16 characters (any characters except white space chars - space or newline), and the value is a decimal integer in the range [-10,000, 10,000].
- Perform grouping: fill an array of structures with 3 values <key>, <value> and <count>, which will include only unique values of <key>. <value> is the cumulative value of all that match the key, <count> is the count of such values.
- Find <average> for all <value> and <count> corresponding to a specific <key>.
- Sort by <average>, and output the key values to stdout (average descending), each key on a separate line.
