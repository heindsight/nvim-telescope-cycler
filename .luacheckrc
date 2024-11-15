-- Rerun tests only if their modification time changed.
cache = true

std = lua51
codes = true

-- Global objects defined by the C code
read_globals = {
  "vim",
}

-- vim: ft=lua
