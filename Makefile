TESTS = $(wildcard programs/test*.py)
TEST_RESULTS = ${TESTS:.py=.out}
TEST_REFERENCE = ${TESTS:.py=.ref}

.PHONY: all test ref clean test-clean jenkins

all:	python-kompiled/base.maude

test: ${TEST_RESULTS}

jenkins: clean
	$(MAKE) jenkins-test

jenkins-test: ${TEST_RESULTS}
	./jenkins-integration.py ${TEST_RESULTS}

ref: ${TEST_REFERENCE}

%.out: %.py python-kompiled/base.maude kpython
	@echo "Testing $<"
	@./kpython $< > $@.tmp
	@- test "`grep "< k > (.).K </ k >" $@.tmp`" && cp $@.tmp $@ && echo "$< passed"


%.ref: %.py
	-PYTHONHASHSEED=1 python3.3 $< > /dev/null 2>&1 && touch $@

python-kompiled/base.maude: ?*.k
	kompile python.k -v --transition "allocation"

clean: test-clean
	rm -rf .k
	rm -rf python-kompiled
	rm -f kompile_*
	rm -f all_tokens.tok
	rm -f kmain-python.maude python.maude shared.maude
	rm -f out
	rm -f IN.maude
	rm -f *.k~
	rm -f *.orig
	rm -f junit-results.xml
	rm -f nohup.out

test-clean:
	rm -f programs/*.out programs/*.ref programs/*.out.tmp
