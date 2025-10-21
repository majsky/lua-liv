return function(path)
    local env = {}
    local chunk, err = loadfile(path, "bt", env)

    if not chunk then
        error(err)
    end

    local status, err = pcall(chunk)

    if not status then
        error(err)
    end

    return env, "lua"
end