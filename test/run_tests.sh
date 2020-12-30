#!/bin/bash
#debug
#set -x

#file for temporary results
TMP_RESULT=$(mktemp)

#helper function
errxit() {
  echo "$1";
  exit 1;
}

# test 1 - check if diff of two general csv files is correct
../csvdiff.pl --idcol ID --file1 _file1.csv --file2 _file2.csv > ${TMP_RESULT}
diff t-res_file1-_file2.csvdiff-colored ${TMP_RESULT} 1>/dev/null || errxit "Test 1 FAIL."
rm ${TMP_RESULT}
echo "Test 1 OK."

# test 1 - check if diff of two general csv files is correct, nocolor
../csvdiff.pl --idcol ID --file1 _file1.csv --file2 _file2.csv --no-color > ${TMP_RESULT}
diff t-res_file1-_file2.csvdiff ${TMP_RESULT} 1>/dev/null || errxit "Test 2 FAIL."
rm ${TMP_RESULT}
echo "Test 2 OK."


# test 3 - check if diff of two general csv files is correct, explicit column separators
../csvdiff.pl --idcol ID --colsep1 , --colsep2 , --colsep-out , --file1 _file1.csv --file2 _file2.csv > ${TMP_RESULT}
diff t-res_file1-_file2.csvdiff-colored ${TMP_RESULT} 1>/dev/null || errxit "Test 3 FAIL."
rm ${TMP_RESULT}
echo "Test 3 OK."

# test 4 - check two files in case-sensitive mode
../csvdiff.pl --idcol ID --file1 _file1.csv --file2 _file3.csv --no-color > ${TMP_RESULT}
diff t-res_file1-_file3.csvdiff-case ${TMP_RESULT} 1>/dev/null || errxit "Test 4 FAIL."
rm ${TMP_RESULT}
echo "Test 4 OK."

# test 5 - check two files in case-insensitive mode
../csvdiff.pl --idcol ID --file1 _file1.csv --file2 _file3.csv --no-color --no-case > ${TMP_RESULT}
diff t-res_file1-_file3.csvdiff-nocase ${TMP_RESULT} 1>/dev/null || errxit "Test 5 FAIL."
rm ${TMP_RESULT}
echo "Test 5 OK."

# test 6 - check two files with structured fields with structure-aware comparison disabled; case-sensitive mode
../csvdiff.pl --idcol ID --file1 _file4.csv --file2 _file5.csv > ${TMP_RESULT}
diff t-res_file4-_file5.csvdiff-colored-nostructure ${TMP_RESULT} 1>/dev/null || errxit "Test 6 FAIL."
rm ${TMP_RESULT}
echo "Test 6 OK."

# test 7 - check two files with structured fields with structure-aware comparison enabled; case-sensitive mode
../csvdiff.pl --idcol ID --file1 _file4.csv --file2 _file5.csv --struct-cols Lastname,Salary --struct-sep \| > ${TMP_RESULT}
diff t-res_file4-_file5.csvdiff-colored-structure ${TMP_RESULT} 1>/dev/null || errxit "Test 7 FAIL."
rm ${TMP_RESULT}
echo "Test 7 OK."

# test 8 - check two files with structured fields with structure-aware comparison enabled; case-insensitive mode
../csvdiff.pl --idcol ID --file1 _file4.csv --file2 _file5.csv --struct-cols Lastname,Salary --struct-sep \| --no-case > ${TMP_RESULT}
diff t-res_file4-_file5.csvdiff-colored-structure-nocase ${TMP_RESULT} 1>/dev/null || errxit "Test 8 FAIL."
rm ${TMP_RESULT}
echo "Test 8 OK."

# test 9 - check two files with structured fields with structure-aware comparison enabled; case-sensitive mode, no coloring
../csvdiff.pl --idcol ID --file1 _file4.csv --file2 _file5.csv --struct-cols Lastname,Salary --struct-sep \| --no-color > ${TMP_RESULT}
diff t-res_file4-_file5.csvdiff-nocolor-structure ${TMP_RESULT} 1>/dev/null || errxit "Test 9 FAIL."
rm ${TMP_RESULT}
echo "Test 9 OK."
