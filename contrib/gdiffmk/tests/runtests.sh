#!/bin/sh
#
#	A very simple function test for gdiffmk.sh.
#
# Copyright (C) 2004-2020, 2023 Free Software Foundation, Inc.
# Written by Mike Bianchi <MBianchi@Foveal.com>.
# Subsequent modifications by G. Branden Robinson.

# This file is part of the gdiffmk utility, which is part of groff.

# groff is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# groff is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# This file is part of GNU gdiffmk.

# abs_top_out_dir is set by AM_TESTS_ENVIRONMENT (defined in
# Makefile.am) when running "make check".

gdiffmk=${abs_top_out_dir:-.}/gdiffmk

# Locate directory containing our test artifacts.
in_dir=

for srcroot in . .. ../..
do
    # Look for a source file characteristic of the groff source tree.
    if ! [ -f "$srcroot"/ChangeLog.115 ]
    then
        continue
    fi

    d=$srcroot/contrib/gdiffmk/tests
    if [ -d "$d" ]
    then
        in_dir=$d
        break
    fi
done

# If we can't find it, we can't test.
if [ -z "$in_dir" ]
then
    echo "$0: cannot locate test artifact input directory" >&2
    exit 77 # skip
fi

# Locate directory where we'll put the test output.
out_dir=

for buildroot in . .. ../..
do
    d=$buildroot/contrib/gdiffmk/tests
    if [ -d "$d" ]
    then
        out_dir=$d
        break
    fi
done

# If we can't find it, we can't test.
if [ -z "$out_dir" ]
then
    echo "$0: cannot locate test artifact output directory" >&2
    exit 77 # skip
fi

exit_code=0	#  Success
failure_count=0

TestResult () {
	if cmp -s $1 $2
	then
		echo $2 PASSED
	else
		echo ''
		echo $2 TEST FAILED
		diff $1 $2
		echo ''
		exit_code=1	#  Failure
		failure_count=`expr ${failure_count} + 1`
	fi
}

CleanUp () {
	rm -f ${out_dir}/result.* ${out_dir}/tmp_file.* ${tmpfile}
}

tmpfile=${TMPDIR:-/tmp}/$$
trap 'trap "" HUP INT QUIT TERM; CleanUp; kill -s INT $$' \
	HUP INT QUIT TERM

#	Run tests.

#	3 file arguments
ResultFile=${out_dir}/result.1
${gdiffmk}  ${in_dir}/file1  ${in_dir}/file2 ${ResultFile} 2>${tmpfile}
cat ${tmpfile} >>${ResultFile}
TestResult ${in_dir}/baseline ${ResultFile}

#	OUTPUT to stdout by default
ResultFile=${out_dir}/result.2
${gdiffmk}  ${in_dir}/file1  ${in_dir}/file2  >${ResultFile} 2>&1
TestResult ${in_dir}/baseline ${ResultFile}

#	OUTPUT to stdout via  -  argument
ResultFile=${out_dir}/result.3
${gdiffmk}  ${in_dir}/file1  ${in_dir}/file2 - >${ResultFile} 2>&1
TestResult ${in_dir}/baseline ${ResultFile}

#	FILE1 from standard input via  -  argument
ResultFile=${out_dir}/result.4
${gdiffmk}  - ${in_dir}/file2 <${in_dir}/file1  >${ResultFile} 2>&1
TestResult ${in_dir}/baseline ${ResultFile}


#	FILE2 from standard input via  -  argument
ResultFile=${out_dir}/result.5
${gdiffmk}  ${in_dir}/file1 - <${in_dir}/file2  >${ResultFile} 2>&1
TestResult ${in_dir}/baseline ${ResultFile}


#	Different values for addmark, changemark, deletemark
ResultFile=${out_dir}/result.6
${gdiffmk}  -aA -cC -dD  ${in_dir}/file1 ${in_dir}/file2  >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.6 ${ResultFile}


#	Different values for addmark, changemark, deletemark
#	Alternate format of -a -c and -d flag arguments
ResultFile=${out_dir}/result.6a
${gdiffmk}  -a A -c C -d D  ${in_dir}/file1 ${in_dir}/file2  >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.6a ${ResultFile}


#	Test for accidental file overwrite.
ResultFile=${out_dir}/result.7
TempFile=${out_dir}/tmp_file.7
cp ${in_dir}/file2 "$TempFile"
${gdiffmk}  -aA -dD -cC  ${in_dir}/file1 "$TempFile"  "$TempFile" \
							>${ResultFile} 2>&1
TestResult ${in_dir}/baseline.7 ${ResultFile}


#	Test -D option
ResultFile=${out_dir}/result.8
${gdiffmk}  -D  ${in_dir}/file1 ${in_dir}/file2 >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.8 ${ResultFile}


#	Test -D  and  -M  options
ResultFile=${out_dir}/result.9
${gdiffmk}  -D  -M '<<<<' '>>>>'				\
			${in_dir}/file1 ${in_dir}/file2 >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.9 ${ResultFile}


#	Test -D  and  -M  options
#	Alternate format of -M argument.
ResultFile=${out_dir}/result.9a
${gdiffmk}  -D  -M'<<<<' '>>>>'				\
			${in_dir}/file1 ${in_dir}/file2 >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.9a ${ResultFile}


#	Test -D  and  -B  options
ResultFile=${out_dir}/result.10
${gdiffmk}  -D  -B  ${in_dir}/file1 ${in_dir}/file2 >${ResultFile} 2>&1
TestResult ${in_dir}/baseline.10 ${ResultFile}


echo failure_count ${failure_count}

# You can comment out the following line to examine failing cases.
CleanUp

exit ${exit_code}

# vim:set ai et sw=4 ts=4 tw=72:
