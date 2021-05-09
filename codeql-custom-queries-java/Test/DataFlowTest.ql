// import java

// from Method fMethod, Call call
// where
// fMethod.hasName("f") and
//   call.getCallee() = fMethod
// select call.getArgument(0)


import java
import semmle.code.java.dataflow.DataFlow

class FromMainToF extends DataFlow::Configuration {
    FromMainToF() { this = "FromMainToF" }
    /**
     * source指示了源是什么
     */
    override predicate isSource(DataFlow::Node source) {
        // exists(Method method |
        //     method.hasName("Main") and 
        //     source.asParameter() = method.getParameter(0)
        // )
        // source.asExpr() instanceof IntegerLiteral
        // source.asExpr().getType().hasName("int")
        exists(Method method, Method nextInt, Call call|
            method.hasName("main") and
            nextInt.getDeclaringType().hasQualifiedName("java.util", "Scanner") and
            nextInt.hasName("nextInt") and
            call.getCaller() = method and
            call.getCallee() = nextInt and
            // exists(Call call2, Method flowTest |
            //     flowTest.hasName("flowTest") and
            //     call2.getCaller() = method and
            //     call2.getCallee() = flowTest |
            //     call.getQualifier() = call2.getArgument(1) and
            //     source.asExpr() = call2.getArgument(1)
            // )
            // nextInt.getReturnType() = source.asExpr().getType()
            call.getQualifier() = source.asExpr()
        )
    }

    /**
     * sink指示了目的地是什么
     */
    override predicate isSink(DataFlow::Node sink) {
        exists(MethodAccess call, Method method |
            method.hasName("f") and 
            call.getMethod() = method and sink.asExpr() = call.getArgument(0)
        )
    }
}

from FromMainToF config, DataFlow::Node source, DataFlow::Node sink
where config.hasFlow(source, sink)
select source, sink