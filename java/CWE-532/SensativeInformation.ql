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
// Internal
import geekmasher.Logging
import geekmasher.SensativeInformation

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
