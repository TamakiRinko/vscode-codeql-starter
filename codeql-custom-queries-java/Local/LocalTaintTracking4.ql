import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.TaintTracking

class MyTaintTrackingConfiguration extends DataFlow::Configuration {
    MyTaintTrackingConfiguration() { this = "MyTaintTrackingConfiguration" }
  
    override predicate isSource(DataFlow::Node source) {
      exists(AssignExpr ae, Method nextInt, Call call|
        nextInt.getDeclaringType().hasQualifiedName("java.util", "Scanner") and
        nextInt.hasName("next") and
        call.getCallee() = nextInt and
        ae.getSource() = call|
        source.asExpr() = ae.getSource()
      )
    }
  
    override predicate isSink(DataFlow::Node sink) {
        exists(MethodAccess call, Method method |
            method.hasName("func") and 
            call.getMethod() = method and sink.asExpr() = call.getArgument(0)
        )
    }
}

from MyTaintTrackingConfiguration mtc, DataFlow::Node src, DataFlow::Node sink
where mtc.hasFlow(src, sink)
select src, sink