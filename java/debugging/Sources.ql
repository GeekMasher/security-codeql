/**
 * @id java/remote-flow-source
 * @kind problem
 * @name Potential source of untrusted data
 * @description Potential source of untrusted data
 * @precision low
 * @severity warning
 * @tags security
 */

import java
import semmle.code.java.dataflow.FlowSources

from RemoteFlowSource rfs
select rfs, "Potential source of untrusted data"
