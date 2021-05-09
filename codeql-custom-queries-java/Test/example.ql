/**
 * @id java/int-search
 * @name Int Search
 * @description Finds int variables
 * @kind problem
 * @problem.severity recommendation
 */

import java

string getIntName(Variable v, PrimitiveType pt){
    pt = v.getType() and
    pt.hasName("int") and
    result = v.getName()
}

from Variable v, PrimitiveType pt
where pt = v.getType() and
    pt.hasName("int")
select v, "variable is " + v.getName(), pt, "type = " + pt.getName()
