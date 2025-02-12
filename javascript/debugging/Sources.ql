/**
 * @name All Sources
 * @kind problem
 * @problem.severity note
 * @precision low
 * @id js/debugging/sources
 * @tags debugging
 */

import stdlib

from AllSources sources
// where
// Filter results to a specific file
// filterByLocation(sources, "app.js", _)
select sources, "All Sources"
