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
import Loggers
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking2
import DataFlow::PathGraph

// ========== Sources ==========
abstract private class SensativeInformationSources extends DataFlow::Node { }

class HttpSession extends SensativeInformationSources {
  HttpSession() {
    // TODO: remove as its used for testing
    exists(MethodAccess ma |
      ma.getMethod().hasName("getProperty") and
      this.asExpr() = ma
    )
    or
    exists(MethodAccess ma |
      // https://docs.oracle.com/javaee/5/api/javax/servlet/http/HttpSession.html
      // Assumption: Nothing from the Session object should be logged
      ma.getMethod().getDeclaringType().hasQualifiedName("javax.servlet.http", "HttpSession") and
      this.asExpr() = ma
    )
    or
    exists(Variable v |
      (
        // User data
        v.getName().toLowerCase().regexpMatch(".*(username|passport|fingerprint|dob|ssi).*")
        or
        // Creds / Secrets / Tokens
        v.getName().toLowerCase().regexpMatch(".*(password|pwd|hash|secret|token|session).*")
      ) and
      this.asExpr() = v.getAnAccess()
    )
  }
}

// ========== Sinks ==========
abstract private class LoggingMethodsSinks extends DataFlow::Node { }

// TODO: Use the exists libs in CodeQL to extend this
// Print to stdout
class PrintMethods extends LoggingMethodsSinks {
  PrintMethods() {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType().hasQualifiedName("java.io", _) and
      ma.getMethod().hasName(["println", "print", "printf", "append", "format", "write"]) and
      this.asExpr() = ma.getArgument(0)
    )
  }
}

// Looging methods
class LoggingMethods extends LoggingMethodsSinks {
  LoggingMethods() {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType() instanceof LoggerType and
      ma.getMethod().hasName(["debug", "trace", "debugf", "debugv"]) and
      //Check low priority log levels which are more likely to be real issues to reduce false positives
      this.asExpr() = ma.getAnArgument()
    )
  }
}

// File Writes
// We are assuming that sensative information should only be placed into
// databases and not files
class FileWriteMethods extends LoggingMethodsSinks {
  FileWriteMethods() {
    exists(MethodAccess ma |
      (
        ma.getMethod().getDeclaringType().hasQualifiedName("java.nio.file", "Files") and
        ma.getMethod().hasName("write")
      ) and
      this.asExpr() = ma.getArgument(0)
    )
  }
}

// ========== Configuration ==========
class SensativeInformationLoggingConfig extends TaintTracking::Configuration {
  SensativeInformationLoggingConfig() { this = "SensativeInformationLoggingConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof SensativeInformationSources
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof LoggingMethodsSinks }
}

// ========== Query ==========
from DataFlow::PathNode source, DataFlow::PathNode sink, SensativeInformationLoggingConfig config
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Sensative data is being logged $@.", source.getNode(),
  "user-provided value"
