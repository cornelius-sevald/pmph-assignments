BACKEND=c

all: lssp-same lssp-sorted lssp-zeros

lssp-same: lssp-same.fut
	futhark $(BACKEND) $<

lssp-sorted: lssp-sorted.fut
	futhark $(BACKEND) $<

lssp-zeros: lssp-zeros.fut
	futhark $(BACKEND) $<

.PHONY: all test bench clean

bench: lssp-same lssp-sorted lssp-zeros
	@for prog in $^; do \
		printf "Benchmarking $$prog \n"; \
		futhark dataset --i32-bounds=-10:10 -b -g [10000000]i32 | ./$$prog -t /dev/stderr -r 10; \
	done
	$(MAKE) clean

test: lssp-same.fut lssp-sorted.fut lssp-zeros.fut
	@for fut in $^; do \
		printf "Testing $$fut \n"; \
		futhark test --backend=$(BACKEND) $$fut; \
	done
	$(MAKE) clean

clean:
	rm -rf lssp-same
	rm -rf lssp-sorted
	rm -rf lssp-zeros
	rm -rf *.c
	rm -rf *.expected
	rm -rf *.actual
