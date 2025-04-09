/**
 * @name Local Sources
 * @kind problem
 * @problem.severity note
 * @precision low
 * @id java/debugging/local-sources
 * @tags debugging
 */

import java
import stdlib

from LocalSources sources
// where
// Filter results to a specific file
// filterByLocation(sources, "app.js", _)
select sources, "Local Sources"
