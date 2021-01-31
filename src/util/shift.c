int logicalRightShift(int x, int n) {
    return (unsigned)x >> n;
}
int arithmeticRightShift(int x, int n) {
    if (x < 0 && n > 0) {
        return x >> n | ~(~0U >> n);
    } else {
        return x >> n;
    }
}
int logical_right_shift(int x, int n){
    int size = sizeof(int) * 8; // usually sizeof(int) is 4 bytes (32 bits)
    return (x >> n) & ~(((0x1 << size) >> n) << 1);
}