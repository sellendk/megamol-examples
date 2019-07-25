--- SSBOSPHERE ---

dataFile = "cinematic_data.mmpld"


mmCreateView("ngsphere", "View3D", "::v3d")

mmCreateModule("SphererRenderer", "::ngsr")
mmSetParamValue("::ngsr::renderMode", "SSBO_Stream")

mmCreateModule("MMPLDDataSource", "::mmpld")
mmSetParamValue("::mmpld::filename", dataFile)

mmCreateCall("CallRender3D",          "::v3d::rendering", "::ngsr::rendering")
mmCreateCall("MultiParticleDataCall", "::ngsr::getdata", "::mmpld::getdata")
