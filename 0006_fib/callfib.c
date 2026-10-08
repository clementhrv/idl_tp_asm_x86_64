#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int64_t fib(int64_t);

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage : %s n\n", argv[0]);
        return 1;
    }

    int64_t n = strtoll(argv[1], NULL, 10);

    printf("%" PRId64 "\n", fib(n));
    return 0;
}
