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

- **Verbose output:**
  ```bash
  make test ARGS="-v"
  ```

- **Run only the TestArray suite:**
  ```bash
  make test ARGS="TestArray"
  ```

- **Run only a specific method:**
  ```
  make test ARGS="TestArray.testEmpty"
  ```

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
