import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.DataFlow

from Expr src, Variable sink, Expr z
where 
    // sink.hasName("y") and
    // sink.getType().hasName("String") and
    TaintTracking::localTaint(DataFlow::exprNode(src), DataFlow::exprNode(z))
select src, z
