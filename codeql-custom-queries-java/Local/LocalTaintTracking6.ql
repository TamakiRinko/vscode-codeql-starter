import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

from Method localTest, Parameter src, DataFlow::Node sink
where localTest.getDeclaringType().hasName("Main") and
    localTest.hasName("localTest") and
    src = localTest.getParameter(0) and
    TaintTracking::localTaintStep+(DataFlow::parameterNode(src), sink)
select sink.getLocation(), src, sink