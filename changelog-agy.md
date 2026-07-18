# Antigravity Changelog

## [2026-07-17]

### Added
- **Radix Tree Pretty Printing**: Implemented the [prettyPrint()](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree.lua) function on the `RadixTree` class. It generates a clean, tree-structured visual representation of the tree's nodes, showing keys and values.
- **Enhanced Test Coverage**: Added 5 new test suites in [radixtree_test.lua](file:///Users/felipeflores/Projects/ffdev/ff-lua/src/collections/radixtree_test.lua):
  - `TestOverwrite` for validating overwrite behavior on insertions.
  - `TestPrefixRemoval` to verify correct behavior during non-exact prefix deletions.
  - `TestAssertions` to enforce validation checks on input parameters.
  - `TestPairsIterator` to ensure the `__pairs` metamethod iterator correctly walks the tree.
  - `TestPrettyPrint` to verify the accuracy of the new hierarchical print output.

### Fixed
- **Prefix Removal Bug**: Resolved a major defect in `RadixTree:remove()` when performing prefix removal (`exact = false`). The previous implementation correctly adjusted `self._len` but failed to clear node values and children, keeping the deleted records in memory. By setting `node._value = nil` and calling `node._children:clear()`, parent node cleanup and leaf pruning are now correctly triggered.
- **LuaRocks Configuration**: Added the missing `ff.collections.radixtree` mapping to [ff-lua-0.18.0-1.rockspec](file:///Users/felipeflores/Projects/ffdev/ff-lua/ff-lua-0.18.0-1.rockspec) to ensure the module is compiled and packaged properly.
