# csvdiff
A PERL tool for diffing CSV files that represent some datasets - useful for comparing data of similar/same structure.

Prints out diff of two CSV files on per-field basis. Both CSV files have to have:
- A column with unique identifier ("uid column") for each row. The column must be named the same in both files. Position of the column should not matter but ideally it should be the leftmost one.
- Both CSV files are sorted by the uid column in the same way.
- Ordering of columns is the same in both files.
- Files can use different column delimiters.
- Files have to use double quotes for value quoting. Value quoting is optional (with ordinary caveats).
- Script assumes both files are "identical" in the count of rows and order of values of the uid column. Because CSV files are compared by-row, a "hole" in the uid column in one file will result in bad diff output.

## Current state of repository
The script is in a "quick and dirty but gets the job done" state. Its code looks accordingly to this fact. No versioning and branches either (so far).

## Usage
#### Installation
Copy the script wherever you like. It uses following PERL packages which should be standard on any Linux distribution. Install them if you do not have them already.
- **Text::CSV**
- **Data::Dumper**
- **Term::ANSIColor**
- **Getopt::Long**

#### Invocation
```
# Synopsis:
#./csvdiff.pl --idcol uid-column --file1 file --file2 file [
  --colsep1 file1-column-separator
  --colsep2 file2-column-separator
  --colsep-out csvdiff-output-column-separator
  --no-color
  --no-case
  --struct-cols
  --struct-sep
  ]

# Example:
# Two CSV files where the uid column is named "ID",
# files are "file1.csv" and "file2.csv". Output columns will be separated by ";".
# We do not want colored output so we specify --no-color.
./csvdiff.pl --idcol ID --file1 file1.csv --file2 file2.csv --colsep-out \; --no-color

# The same example for case-insensitive comparison.
./csvdiff.pl --idcol ID --file1 file1.csv --file2 file2.csv --colsep-out \; --no-color --no-case
```

**Notable features**
- Utility can now compare CSV fields that have some internal structure hidden in the textual representation (i.e. arrays and lists). If fields in a list have a separator, you can make csvdiff aware of it. csvdiff then explodes those fields and compares them as two sets of elements. This is useful in cases where two lists have the same values in them but their representation as a serialized string differs.
  - Use **--struct-cols** parameter to specify which CSV columns should be checked with structure-aware comparison. Parameter takes comma-separated list of column names. Example: `--struct-cols Firstname,Salary` to specify two columns, "Firstname" and "Salary".
  - Use **--struct-sep** parameter to specify a separator of a list inside a field value. Only one separator is allowed. Example: Field with value "role1|role2|role3" has a `--struct-sep \|` (backslash is just an escape character because shell).

#### Output
Script outputs four lines for each row where there is something different. Sample output is this:
```
uid column: uid value                 #so you can easily find what rows are diffed
  "column1","column2","column2",...   #list of columns whose values differ
< "val1","val2","val3",...            #values of those columns form file1
> "vval1","vval2","vval3",...         #values of those columns form file2
```
If uid column values of currently compared rows do not match, rows are considered completely different and whole lines are printed into diff.

#### Tests
Tests are located in the **test** folder. You can invoke them by running **./run_tests.sh** from inside the folder. So far, there are only tests for general correct behavior of the csvdiff, just to establish a baseline.
