import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

from Method next, Call call, DataFlow::Node src, DataFlow::Node sink
where next.getDeclaringType().hasQualifiedName("java.util", "Scanner") and
    next.hasName("next") and
    call.getCallee() = next and
    src.asExpr() = call and
    DataFlow::localFlowStep+(src, sink)
select sink.getLocation(), src, sink