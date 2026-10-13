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

- **Run all tests (recommended):**
  ```bash
  make test
  ```

- **Run tests for one module:**
  ```bash
  make test MODULE=ff.collections.array
  ```

`MODULE` must match module name from rockspec, such as `ff.collections.array`.
Omit `MODULE` to run tests for all modules.

## Development & Build Commands

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

## License

MIT
