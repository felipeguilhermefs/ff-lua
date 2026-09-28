# ff-lua

Useful functions and data structures in Lua.

## Requirements

- **Lua:** 5.5+
- **LuaRocks:** 3.0+

## Installation

Install dependencies and package using LuaRocks (target Lua 5.5):

```bash
make install
```

## Testing

### Running Tests

- **Run all tests (via LuaRocks):**
  ```bash
  make test
  ```

### CLI Options & Filtering Examples

Pass arguments to `make test` using `ARGS="..."`:

- **Pattern filtering (run only tests matching a name pattern):**
  ```bash
  # Run all tests matching "Heap"
  make test ARGS="-p Heap"

  # Run all tests matching "Concat" or "Equality"
  make test ARGS="-p Concat -p Equality"
  ```

- **Run a specific test suite or test method:**
  ```bash
  make test ARGS="TestArray"
  ```

For comprehensive testing architecture, style standards, and audit findings, see [luaunit.md](luaunit.md).

## Development & Build Commands

- **Run Tests:**
  ```bash
  make test
  ```
- **Lint Rockspec:**
  ```bash
  make lint
  ```
- **Build Rock Binary:**
  ```bash
  make build
  ```
- **Pack Rock:**
  ```bash
  make pack
  ```
- **Publish to LuaRocks:**
  ```bash
  make publish
  ```

## Architecture & Documentation

- [src/collections/collections.md](src/collections/collections.md): Architectural standards, canonical collection templates, and design patterns.

## License

MIT
