/**
 * @name Partial Path Query from Source
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @id go/debugging/partial-path-from-source
 * @tags debugging
 */

import go
import geekmasher.Utils

module FlowConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof UntrustedFlowSource }

  predicate isSink(DataFlow::Node sink) { any() }
}

int explorationLimit() { result = 10 }

module Flow = DataFlow::Global<FlowConfig>;

module FlowPartial = Flow::FlowExplorationFwd<explorationLimit/0>;

import FlowPartial::PartialPathGraph

from FlowPartial::PartialPathNode source, FlowPartial::PartialPathNode sink
where FlowPartial::partialFlow(source, sink, _)
// and findByLocation(source.getNode(), "main.go", _)
select sink.getNode(), source, sink, "Partial Graph $@.", source.getNode(), "user-provided value"
