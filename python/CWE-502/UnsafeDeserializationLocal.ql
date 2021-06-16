/**
 * @name Deserializing untrusted input
 * @description Deserializing user-controlled data may allow attackers to execute arbitrary code.
 * @kind path-problem
 * @id py/unsafe-deserialization
 * @problem.severity error
 * @security-severity 5.9
 * @sub-severity high
 * @precision low
 * @tags external/cwe/cwe-502
 *       security
 *       serialization
 *       local
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.BarrierGuards

import geekmasher.LocalSources

/**
 * A taint-tracking configuration for detecting arbitrary code execution
 * vulnerabilities due to deserializing user-controlled data.
 */
class UnsafeDeserializationConfiguration extends TaintTracking::Configuration {
  UnsafeDeserializationConfiguration() { this = "UnsafeDeserializationConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof LocalSources }

  override predicate isSink(DataFlow::Node sink) {
    exists(Decoding d |
      d.mayExecuteInput() and
      sink = d.getAnInput()
    )
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof StringConstCompare
  }
}

from UnsafeDeserializationConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Deserializing of $@.", source.getNode(), "untrusted input"
