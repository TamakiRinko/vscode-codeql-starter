/**
 * @id java/int-search
 * @name Int Search
 * @description Finds int variables
 * @kind problem
 * @problem.severity recommendation
 */

import java

from Variable v, PrimitiveType pt
where pt = v.getType() and
    pt.hasName("int")
select v, "variable is " + v.getName(), pt, "type = " + pt.getName()
