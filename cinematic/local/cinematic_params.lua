-- Cinematic Camera Parameters --

local cinematic = 
{
    basePath      = "D:\\03_megamol\\cinematic\\"                , -- Base path 
    width         = 1000                                         , -- Cinematic Viewport Width    (must be > 0)
    height        = 500                                          , -- Cinematic Viewport Height   (must be > 0)
    fps           = 24                                           , -- Cinematic Frames Per Second (must be > 0)
    background    = "blue"                                       , -- The background color.
    keyframeFile  = "cinematic_keyframes.kf"                     , -- The keyframe file to load.
    luaFileToLoad = "ssbosphere.lua"                             , -- The lua project file to load.    
}

return cinematic