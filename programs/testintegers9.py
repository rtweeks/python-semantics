assert hash(0) == 0
assert hash(1) == 1
assert hash(-1) == -2
assert hash(-2) == -2
assert hash(2305843009213693951) == 0
assert hash(2305843009213693952) == 1
assert hash(-2305843009213693951) == 0
assert hash(-2305843009213693952) == -2
assert hash(-2305843009213693953) == -2
