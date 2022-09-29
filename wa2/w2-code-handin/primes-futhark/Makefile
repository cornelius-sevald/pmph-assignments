BACKEND?=c

PROGS=primes-flat primes-naive 
# Only consider primes-seq if using C backend
ifeq ($(BACKEND), c)
	PROGS+=primes-seq
endif
SRCS=$(patsubst %,%.fut,$(PROGS))

all: $(PROGS)

$(PROGS): %: %.fut
	futhark $(BACKEND) $<

.PHONY: all test bench clean

bench: $(PROGS)
	@for prog in $^; do \
		printf "Benchmarking $$prog \n"; \
		echo "10000000" | ./$$prog -t /dev/stderr -r 10 > /dev/null; \
	done
	$(MAKE) clean

test: $(SRCS)
	@for fut in $^; do \
		printf "Testing $$fut \n"; \
		futhark test --backend=$(BACKEND) $$fut; \
	done
	$(MAKE) clean

clean:
	rm -rf $(PROGS)
	rm -rf *.c
	rm -rf *.expected
	rm -rf *.actual
