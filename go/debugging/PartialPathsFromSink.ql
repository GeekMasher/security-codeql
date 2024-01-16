/**
 * @name Partial Path Query from Sink
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @id go/debugging/partial-path-from-sink
 * @tags debugging
 */

import go
import geekmasher.Utils

module FlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { any() }

  predicate isSink(DataFlow::Node sink) { sink instanceof Sinks }
}

int explorationLimit() { result = 10 }

module Flow = DataFlow::Global<FlowConfig>;

module FlowPartial = Flow::FlowExplorationRev<explorationLimit/0>;

import FlowPartial::PartialPathGraph

from FlowPartial::PartialPathNode source, FlowPartial::PartialPathNode sink
where FlowPartial::partialFlow(source, sink, _)
/// Find by location in the code
// and findByLocation(source.getNode(), "main.ql", _)
select sink.getNode(), source, sink, "Partial Graph $@.", source.getNode(), "user-provided value"
