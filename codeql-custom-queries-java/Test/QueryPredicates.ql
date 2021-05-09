import java

query int getProduct(int x, int y){
    x in [1 .. 2] and
    y in [2 .. 4] and
    result = x * y
}

int getProduct2(int x, int y){
    x = 3 and
    y in [0 .. 5] and
    result = x * y
}

class MultipleOfThree extends int {
    MultipleOfThree() { this = getProduct(_, _) }
}

bindingset[i]
predicate isOdd(int i) {
  i % 2 = 0
}
// from MultipleOfThree m
from int i
where i in [1, 2, 3, 4, 5] and isOdd(i)
select i