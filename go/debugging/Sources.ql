/**
 * @name Sources
 * @kind problem
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @id go/debugging/sources
 * @tags debugging
 */

import go
import semmle.go.security.FlowSources
import geekmasher.Utils

from UntrustedFlowSource sources
select sources, "source"
