#!/bin/bash
#debug
#set -x

#file for temporary results
TMP_RESULT="res.tmp"

#helper function
errxit() {
  echo "$1";
  exit 1;
}

# test 1 - check if diff of two general csv files is correct
../csvdiff.pl ID , _file1.csv _file2.csv > ${TMP_RESULT}
diff _file1-_file2.csvdiff-colored ${TMP_RESULT} 1>/dev/null || errxit "Test 1 FAIL."
rm ${TMP_RESULT}
echo "Test 1 OK."
