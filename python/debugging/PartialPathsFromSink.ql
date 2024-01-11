/**
 * @name Partial Path Query from Sink
 * @id py/debugging/partial-path-from-sink
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @tags debugging
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.RemoteFlowSources
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs
// GH Security Lab Library
import ghsl.Helpers
// Shared libraries
import geekmasher.Utils

/**
 * Manual Sinks
 */
class ManualSinks extends DataFlow::Node {
  ManualSinks() { this = API::moduleImport("any").getMember("any").getACall() }
}

/*
 * Partial Graph module interface
 */

module RemoteFlowsConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { any() }

  predicate isSink(DataFlow::Node sink) {
    // Dangerous Sinks (SQLi, XSS, etc)
    dangerousSinks(sink)
    or
    // Manual Sinks
    sink instanceof ManualSinks
  }
}

// Set the limit of the exloration depth
int explorationLimit() { result = 10 }

module RemoteFlows = DataFlow::Global<RemoteFlowsConfig>;

module RemoteFlowsPartial = RemoteFlows::FlowExplorationRev<explorationLimit/0>;

import RemoteFlowsPartial::PartialPathGraph

from RemoteFlowsPartial::PartialPathNode source, RemoteFlowsPartial::PartialPathNode sink
where RemoteFlowsPartial::partialFlow(source, sink, _)
/// Filter sources to just Function / Call arguments
// and source.getNode() instanceof FunctionArgs
///
/// Filter by location
// and findByLocation(source.getNode(), "app.py", 20)
///
/// Filter by Function Parameters
// and functionParameters(source.getNode())
//
select sink.getNode(), source, sink, "Partial Graph $@.", source.getNode(), "user-provided value"
