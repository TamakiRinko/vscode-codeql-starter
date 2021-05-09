import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources

from DataFlow::Node src, DataFlow::Node sink
where src instanceof RemoteFlowSource and
    DataFlow::localFlowStep+(src, sink)
select sink.getLocation(), src, sink