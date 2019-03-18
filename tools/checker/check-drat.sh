#!/bin/bash
#
# Solver the given input formula, and in case of being unsatisfiable, the
# produced proof is checked by drat-trim. The produced proof is generated
# in the binary of plain format.

# input
f="$1"
shift

# check for file
[ -f "$f" ] || exit 2

# static variables
p=p.proof
o=drat-minimize-output.txt
t=$(readlink -e ../../build/release/bin/minisat)
d=$(readlink -e drat-trim)

P=$(( ( RANDOM % 1 ) ))
BINPROOF="-bin-proof"
[ "$P" -ne 0 ] || BINPROOF=""

# run solver
STATUS=0
$t $f -proof=$p $BINPROOF $@ || STATUS=$?

if [ "$STATUS" -ne 0 ] && [ "$STATUS" -ne 10 ] && [ "$STATUS" -ne 20 ]
then
	echo "unexpected status code $STATUS"
	exit $STATUS
fi

# exclude trivial unsat
grep "^0$" $f && exit 0

# run the check
if [ "$STATUS" -eq 20 ]
then
	VERIFY_STATUS=0
	$d $f $p -v -v -n &> $o || exit $VERIFY_STATUS
	echo "verify status: $VERIFY_STATUS"
	grep " does not occur: " $o && exit 2
	exit 20
fi
exit "$STATUS"
