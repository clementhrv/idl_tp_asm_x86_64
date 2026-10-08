#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int64_t gcd(int64_t, int64_t);

int main(int argc, char **argv)
{
    if (argc != 3) {
        fprintf(stderr, "Usage : %s a b\n", argv[0]);
        return 1;
    }

    int64_t a = strtoll(argv[1], NULL, 10);
    int64_t b = strtoll(argv[2], NULL, 10);

    printf("%" PRId64 "\n", gcd(a, b));
    return 0;
}
