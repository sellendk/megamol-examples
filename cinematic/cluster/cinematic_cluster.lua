﻿-- Cinematic MegaMol Project File --

print(">>> I am the MegaMol VISUS Cinematic cluster project!")

-- Parameters --
headNode         = mmGetConfigValue("headNode")
renderHead       = mmGetConfigValue("renderHead")
 
role             = mmGetConfigValue("role")
rank             = mmGetEnvValue("PMI_RANK")

cc_width_str     = mmGetConfigValue("cinematic_width")
cc_height_str    = mmGetConfigValue("cinematic_height")
cc_fps_str       = mmGetConfigValue("cinematic_fps")

cc_luaFileToLoad = mmGetConfigValue("cinematic_luaFileToLoad")
cc_keyframeFile  = mmGetConfigValue("cinematic_keyframeFile")
cc_background    = mmGetConfigValue("cinematic_background")

aggregate        = "true" -- use IceT to composite inside MPI WORLD before rank 0 (and only that!) transmits.


-- Function for loading lua project file --
function trafo(str)
    local newcontent = str:gsub('mmCreateView%(.-%)', "")
    local viewname, viewclass, viewmoduleinst = str:match(
        'mmCreateView%(%s*[\"\']([^\"\']+)[\"\']%s*,%s*[\"\']([^\"\']+)[\"\']%s*,%s*[\"\']([^\"\']+)[\"\']%s*%)')

    print("viewname = " .. viewname)
    print("viewclass = " .. viewclass)
    print("viewmoduleinst = " .. viewmoduleinst)

    newcontent = newcontent:gsub('mmCreateCall%([\"\']CallRender3D_2[\'\"],%s*[\'\"]' 
        .. '.-' .. viewmoduleinst .. '::rendering[\'\"],([^,]+)%)', 'mmCreateCall("CallRender3D_2", "::mpi_lua::v::rendering",%1)')

    return newcontent
end


if role == "head" then

    mmCreateJob("simpleclusterserver", "SimpleClusterServer",    "::scs")
    mmSetParamValue("::scs::viewname",                           "::mpi_lua::v")
    mmSetParamValue("::scs::server::Name",                       headNode) 
    mmSetParamValue("::scs::udptarget",                          renderHead)
    mmSetParamValue("::scs::server::noEcho",                     "true")
        
    mmCreateView("mpi_lua", "CinematicView", "v")
    mmSetParamValue("::mpi_lua::v::backCol",                    "grey") 
    mmSetParamValue("::mpi_lua::v::cinematic::cinematicWidth",  cc_width_str)
    mmSetParamValue("::mpi_lua::v::cinematic::cinematicHeight", cc_height_str)
    mmSetParamValue("::mpi_lua::v::cinematic::fps",             cc_fps_str)   
    mmSetParamValue("::mpi_lua::v::cinematic::firstFrame",      "0")        
    mmSetParamValue("::mpi_lua::v::cinematic::delayFirstFrame", "10.000000")    

    mmCreateModule("FBOCompositor2", "::mpi_lua::fboc")
    mmSetParamValue("::mpi_lua::fboc::NumRenderNodes",          "1")
    mmSetParamValue("::mpi_lua::fboc::communicator",            "ZMQ")
    mmSetParamValue("::mpi_lua::fboc::handshakePort",           "42000")
    mmSetParamValue("::mpi_lua::fboc::targetBandwidth",         "100")
    mmSetParamValue("::mpi_lua::fboc::only_requested_frames",   "true")

    mmCreateModule("KeyframeKeeper", "::mpi_lua::kfk")
    mmSetParamValue("::mpi_lua::kfk::storage::filename",        cc_keyframeFile)

    mmCreateCall("CallKeyframeKeeper",  "::mpi_lua::v::keyframeKeeper", "::mpi_lua::kfk::scene3D")
    mmCreateCall("CallRender3D_2",      "::mpi_lua::v::rendering",      "::mpi_lua::fboc::rendering")

else

    print(">>> I am a " .. string.upper(role) .. " running as rank " .. rank)

    mmCreateModule("View3D_2", "::mpi_lua::v") 
    --mmCreateView("mpi_lua", "View3D", "v") 

    mmSetParamValue("::mpi_lua::v::backCol",                  cc_background)
    mmSetParamValue("::mpi_lua::v::viewcube::show",           "false")
    
    mmCreateModule("FBOTransmitter2", "::mpi_lua::fbot")
    mmSetParamValue("::mpi_lua::fbot::tiledDisplay",          "true") 
    mmSetParamValue("::mpi_lua::fbot::view",                  "::mpi_lua::v")
    mmSetParamValue("::mpi_lua::fbot::aggregate",             aggregate)
    mmSetParamValue("::mpi_lua::fbot::communicator",          "ZMQ")
    mmSetParamValue("::mpi_lua::fbot::handshakePort",         "42000")
    mmSetParamValue("::mpi_lua::fbot::port",                  tostring(34230 + rank)) -- 34242 or 34230
    mmSetParamValue("::mpi_lua::fbot::targetMachine",         headNode)  
    if (headNode == "localhost" or headNode == "127.0.0.1") then
        mmSetParamValue("::mpi_lua::fbot::force_localhost",  "true")
    end     
    mmSetParamValue("::mpi_lua::fbot::trigger",               " ") -- Must be set!!!

    if (aggregate == "true") then
        mmCreateModule("MPIProvider", "::mpi_lua::mpi")
        mmCreateCall("MpiCall", "::mpi_lua::fbot::requestMpi", "::mpi_lua::mpi::provideMpi")
    end
      
    -- Loading lua project file --
    local content = mmReadTextFile(cc_luaFileToLoad, trafo)
    print("read: " .. content)
    code = load(content)
    code()

end