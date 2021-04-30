
import java


int aa(int i, int j) {
    i = 2 and j = 3 and result = 5
    or
    i = 5 and j = 6 and result = 10
    or
    i = 7 and j = 6 and result = 12
    or
    i = 10 and j = 7 and result = 15
}

// from ArrayCreationExpr arraycreation
// where count(Expr r | r = arraycreation.getADimension() | r) > 1
// select arraycreation.getADimension()

// select getAccessNum()

from ArrayAccess aa
select aa


query int getAccessNum(){
    result = count(ArrayAccess aa)
}