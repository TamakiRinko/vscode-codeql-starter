import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

from Method method, Call call, Expr src
where method.hasName("func") and
    method = call.getCallee() and
    DataFlow::localFlow(DataFlow::exprNode(src), DataFlow::exprNode(call.getArgument(0)))
select src.getLocation(), src, src.getType(), call.getArgument(0)