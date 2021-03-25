/**
 * @name Sensative information exposure through logging
 * @description Sensative information exposure through logging
 * @kind path-problem
 * @problem.severity warning
 * @precision medium
 * @id java/sensative-information-logging
 * @tags security
 *       external/cwe/cwe-532
 */

import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking2
import DataFlow::PathGraph

// ========== Sources ==========
abstract private class SensativeInformationSources extends Method { }

class HttpSession extends SensativeInformationSources {
  HttpSession() {
    // TODO: remove as its used for testing
    this.hasName("getProperty")
    or
    // https://docs.oracle.com/javaee/5/api/javax/servlet/http/HttpSession.html
    // Assumption: Nothing from the Session object should be logged
    this.getDeclaringType().hasQualifiedName("javax.servlet.http", "HttpSession")
  }
}

// ========== Sinks ==========
abstract private class LoggingMethodsSinks extends DataFlow::Node { }

// TODO: Use the exists libs in CodeQL to extend this
class PrintMethods extends LoggingMethodsSinks {
  PrintMethods() {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType().hasQualifiedName("java.io", _) and
      (
        ma.getMethod().hasName("println") or
        ma.getMethod().hasName("print") or
        ma.getMethod().getName() = "append" or
        ma.getMethod().getName() = "format" or
        ma.getMethod().getName() = "write"
      ) and
      this.asExpr() = ma.getArgument(0)
    )
  }
}

// ========== Configuration ==========
class SensativeInformationLoggingConfig extends DataFlow::Configuration {
  SensativeInformationLoggingConfig() { this = "SensativeInformationLoggingConfig" }

  override predicate isSource(DataFlow::Node source) {
    exists(MethodAccess ma |
      source.asExpr() = ma and ma.getMethod() instanceof SensativeInformationSources
    )
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof LoggingMethodsSinks }

  override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    TaintTracking::localTaintStep(node1, node2)
  }
}

// ========== Query ==========
from DataFlow::PathNode source, DataFlow::PathNode sink, SensativeInformationLoggingConfig config
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Sensative data is being logged $@.", source.getNode(),
  "user-provided value"
