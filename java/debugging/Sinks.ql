/**
 * @name List out all known sinks
 * @kind problem
 * @problem.severity warning
 * @security-severity 1.0
 * @sub-severity low
 * @precision low
 * @id java/debugging/sources
 * @tags debugging
 */

import java
import Helper

from AllSinks sinks
select sinks, "sinks"
