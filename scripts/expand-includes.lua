-- Expands the include macros of markdown/main.md into one Markdown file.
-- Replaces the old Python "moustache" handler; only the macros this document uses are supported:
--   {{include FILE}}     insert FILE (path relative to the main file), recursively
--   {{github_release}}   release label, given as the third argument (default "Draft")
--   {{draft-version}}    "<origin url>:<tag or branch> sha: <8 chars> at: <UTC date time>"
-- Any other {{macro}} is an error, so a typo cannot silently end up in the document.
--
-- Usage: pandoc lua scripts/expand-includes.lua <main.md> <out.md> [release-label]

local infile, outfile, release = arg[1], arg[2], arg[3] or "Draft"
if not infile or not outfile then
  io.stderr:write("Usage: pandoc lua expand-includes.lua <main.md> <out.md> [release-label]\n")
  os.exit(2)
end

local function sh(cmd)
  local p = io.popen(cmd .. " 2>/dev/null")
  local out = p:read("*a"):gsub("%s+$", "")
  p:close()
  return out
end

local function draft_version()
  local origin = sh("git remote get-url origin")
  local ref = sh("git describe --tags --exact-match HEAD")
  if ref == "" then ref = sh("git rev-parse --abbrev-ref HEAD") end
  local sha = sh("git rev-parse HEAD"):sub(1, 8)
  return string.format("%s:%s sha: %s at: %s", origin, ref, sha, os.date("!%Y-%m-%d %H:%M:%S"))
end

local root = infile:match("^(.*)/[^/]*$") or "."
local out = {}

local function macro(name, args, depth)
  if name == "include" then
    return args and process(root .. "/" .. args, depth + 1) or error("include needs a file name")
  elseif name == "github_release" then
    return release
  elseif name == "draft-version" then
    return draft_version()
  end
  error("unknown macro {{" .. name .. "}} - supported: include, github_release, draft-version")
end

function process(path, depth)
  if depth > 10 then error("include nesting too deep at " .. path) end
  local f = assert(io.open(path, "rb"))
  local text = f:read("*a")
  f:close()
  text = text:gsub("\r\n", "\n")                 -- the sources have mixed line endings
  local result = {}
  for line, eol in text:gmatch("([^\n]*)(\n?)") do
    if line ~= "" or eol ~= "" then
      line = line:gsub("{{%s*([%w_%-]+)%s*(.-)%s*}}", function(name, args)
        return macro(name, args ~= "" and args or nil, depth)
      end)
      result[#result + 1] = line .. eol
    end
  end
  return table.concat(result)   -- no newline is added: an included file joins the line after its macro
end

local f = assert(io.open(outfile, "wb"))
f:write(process(infile, 0))
f:close()
