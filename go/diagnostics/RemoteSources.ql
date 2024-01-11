/**
 * @name Remote Sources Summary
 * @id go/diagnostics/remote-sources
 * @description List all remote sources that can be used to compromise the confidentiality or integrity of the system.
 * @kind diagnostic
 * @tags diagnostic
 */

import go
import semmle.go.security.FlowSources

from UntrustedFlowSource s
where not s.getFile().getRelativePath().matches("%/test/%")
select s, ""
