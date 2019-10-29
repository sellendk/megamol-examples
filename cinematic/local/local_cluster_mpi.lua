mmCreateView("t1", "MpiClusterView", "::t1::mcview")

mmCreateModule("SimpleClusterClient", "::mcc")
mmCreateModule("MpiProvider", "::mpi")

mmCreateCall("SimpleClusterClientViewRegistration", "::t1::mcview::register", "::mcc::registerView")
mmCreateCall("MpiCall", "::t1::mcview::requestMpi", "::mpi::provideMpi")
