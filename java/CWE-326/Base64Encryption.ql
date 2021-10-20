/**
 * @name Weak Encryption of Sensitive Information
 * @description Weak Encryption of Sensitive Information using Base64
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
// Internal
import geekmasher.SensativeInformation

class Base64Sinks extends DataFlow::Node {
  Base64Sinks() {
    exists(MethodAccess ma |
      ma.getMethod().getDeclaringType().hasQualifiedName("java.util", "Base64$Encoder") and
      this.asExpr() = ma
    )
  }
}

class Base64EncryptionConfig extends TaintTracking::Configuration {
  Base64EncryptionConfig() { this = "Base64EncryptionConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof SensativeInformationSources
  }

  override predicate isSink(DataFlow::Node sink) { sink instanceof Base64Sinks }
}

// ========== Query ==========
from DataFlow::PathNode source, DataFlow::PathNode sink, Base64EncryptionConfig config
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Sensative data is being logged $@.", source.getNode(),
  "user-provided value"
