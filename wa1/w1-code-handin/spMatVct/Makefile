SRC=spMVmult-flat.fut spMVmult-seq.fut
EXE=spMVmult-flat spMVmult-seq
BACKEND=c

all: $(EXE)

spMVmult-flat: spMVmult-flat.fut
	futhark $(BACKEND) $<

spMVmult-seq: spMVmult-seq.fut
	futhark $(BACKEND) $<

.PHONY: all test bench clean

bench: $(EXE)
	@for prog in $^; do \
		printf "Benchmarking $$prog \n"; \
		futhark dataset --i64-bounds=0:9999 -g [1000000]i64 --f32-bounds=-7.0:7.0 -g [1000000]f32 --i64-bounds=100:100 -g [10000]i64 --f32-bounds=-10.0:10.0 -g [10000]f32 | ./$$prog -t /dev/stderr -r 10 2>&1 | head; \
	done
	$(MAKE) clean

test: $(SRC)
	@for fut in $^; do \
		printf "Testing $$fut \n"; \
		futhark test --backend=$(BACKEND) $$fut; \
	done
	$(MAKE) clean

clean:
	rm -rf $(EXE)
	rm -rf *.c
	rm -rf *.expected
	rm -rf *.actual
