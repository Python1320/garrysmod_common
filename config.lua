-- These default paths are relative to the premake5.lua file (or whatever you named it) of your project
-- They can be absolute paths too if you so desire
-- Default path for the workspace files
DEFAULT_WORKSPACE_DIRECTORY = os.target() .. "/" .. _ACTION

-- Default path for the source files (beware this will be used by all projects)
DEFAULT_SOURCE_DIRECTORY = "../source"

-- Default path for the SourceSDK files (root of the source code)
DEFAULT_SOURCESDK_DIRECTORY = nil

-- Default path for the GarrysMod/garrysmod/lua/bin directory (where the compiled files will be copied to)
DEFAULT_GARRYSMOD_LUA_BIN_DIRECTORY = nil
