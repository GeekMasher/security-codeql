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

// Ref :: https://github.com/github/codeql/blob/main/java/ql/src/experimental/Security/CWE/CWE-532/SensitiveInfoLog.ql
// Ref :: https://github.com/github/codeql/blob/main/java/ql/src/experimental/semmle/code/java/Logging.qll#L34
class LoggerType extends RefType {
  LoggerType() {
    this.hasQualifiedName("org.apache.log4j", "Category") or // Log4j 1
    this.hasQualifiedName("org.apache.logging.log4j", ["Logger", "LogBuilder"]) or // Log4j 2
    this.hasQualifiedName("org.apache.commons.logging", "Log") or
    // JBoss Logging (`org.jboss.logging.Logger` in some implementations like JBoss Application Server 4.0.4 did not implement `BasicLogger`)
    this.hasQualifiedName("org.jboss.logging", ["BasicLogger", "Logger"]) or
    this.hasQualifiedName("org.slf4j.spi", "LoggingEventBuilder") or
    this.hasQualifiedName("org.slf4j", "Logger") or
    this.hasQualifiedName("org.scijava.log", "Logger") or
    this.hasQualifiedName("com.google.common.flogger", "LoggingApi") or
    this.hasQualifiedName("java.lang", "System$Logger") or
    this.hasQualifiedName("java.util.logging", "Logger") or
    this.hasQualifiedName("android.util", "Log")
  }
}

class LoggingMethods extends LoggingMethodsSinks {
  LoggingMethods() {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType() instanceof LoggerType and
      (
        ma.getMethod().hasName("debug") or
        ma.getMethod().hasName("trace") or
        ma.getMethod().hasName("debugf") or
        ma.getMethod().hasName("debugv")
      ) and //Check low priority log levels which are more likely to be real issues to reduce false positives
      this.asExpr() = ma.getAnArgument()
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
