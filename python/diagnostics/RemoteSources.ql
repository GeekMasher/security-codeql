/**
 * @name Remote Sources Diagnostic
 * @id python/diagnostics/remote-sources
 * @description List all remote sources that can be used to compromise the confidentiality or integrity of the system.
 * @kind diagnostic
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.RemoteFlowSources

from RemoteFlowSource s, Expr n
where
  s.getScope().inSource() and
  n = s.asExpr()
select n, ""
