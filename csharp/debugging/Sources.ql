/**
 * @id cs/remote-flow-source
 * @kind problem
 * @name Potential source of untrusted data
 * @description Potential source of untrusted data
 * @precision low
 * @severity warning
 * @tags security
 */

import csharp
import semmle.code.csharp.dataflow.flowsources.Remote

from RemoteFlowSource rfs
select rfs, "Potential source of untrusted data"
