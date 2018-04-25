# csvdiff
A PERL tool for diffing CSV files that represent some datasets - useful for comparing data of similar/same structure.

Prints out diff of two CSV files on per-field basis. Both CSV files have to have:
- A column with unique identifier ("uid column") for each row. The column must be named the same in both files. Position of the column should not matter but ideally it should be the leftmost one.
- Both CSV files are sorted by the uid column in the same way.
- Ordering of columns is the same in both files.
- Files have to use the same column delimiter.
- Files have to use double quotes for value quoting. Value quoting is optional (with ordinary caveats).
- Script assumes both files are "identical" in the count of rows and order of values of the uid column. Because CSV files are compared by-row, a "hole" in the uid column in one file will result in bad diff output.

## Current state of repository
The script is in a "quick and dirty but gets the job done" state. Its code looks accordingly to this fact. No versioning and branches either (so far).

## Usage
#### Installation
It's a script, just copy it somewhere. It uses **Text::CSV**, **Data::Dumper** and **Term::ANSIColor** packages. Install them if you do not have them already.

#### Invocation
```
#./csvdiff.pl delimiter uid-column file1 file2
./csvdiff.pl , ID file1.csv file2.csv
```

#### Output
Script outputs about four lines for each row where there is something different. Sample output is this:
```
uid column: uid value                 #so you can easily find what rows are diffed
  "column1","column2","column2",...   #list of columns whose values differ
< "val1","val2","val3",...            #values of those columns form file1
> "vval1","vval2","vval3",...         #values of those columns form file2
```
If uid column values of currently compared rows do not match, rows are considered completely different and whole lines are printed into diff.

#### Tests
Tests are located in the **test** folder. You can invoke them by running **./run_tests.sh** from inside the folder. So far, there is only one test for general correct behavior of the csvdiff, just to establish a baseline.
