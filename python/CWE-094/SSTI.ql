/**
 * @name Server Side Template Injection (SSTI)
 * @description Server Side Template Injection (SSTI)
 * @kind problem
 * @problem.severity error
 * @id js/ssti
 * @tags security
 *       external/cwe/cwe-094
 */

import python
import semmle.python.security.Paths
import semmle.python.web.HttpRequest
import semmle.python.dataflow.TaintTracking
import semmle.python.security.strings.Untrusted
import SSTI

class SSTIConfiguration extends TaintTracking::Configuration {
  SSTIConfiguration() { this = "Server Side Template Injection" }

  override predicate isSource(TaintTracking::Source source) {
    source instanceof HttpRequestTaintSource
  }

  override predicate isSink(TaintTracking::Sink sink) { sink instanceof TemplateSinks }

  // HTML escaping does nothing
  override predicate isSanitizer(Sanitizer sanitizer) { none() }
}

from SSTIConfiguration config, TaintedPathSource src, TaintedPathSink sink
where config.hasFlowPath(src, sink)
select sink.getSink(), src, sink, "$@ flows to here and is interpreted as template code.",
  src.getSource(), "A user-provided value"
