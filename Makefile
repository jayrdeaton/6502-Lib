CONFIG = 6502
RNG_HARNESS = RNG-Harness

.PHONY: all build-rng-harness clean

all: build-rng-harness

build-rng-harness: examples/rng_harness.asm core/rng.asm include/rng.inc
	cl65 -t none -C $(CONFIG).cfg -l $(RNG_HARNESS).lst -o $(RNG_HARNESS).crt examples/rng_harness.asm

clean:
	rm -f $(RNG_HARNESS).crt $(RNG_HARNESS).lst
