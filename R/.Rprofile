Sys.setenv("DISPLAY"=":0.0")
Sys.setenv("R_INTERACTIVE_DEVICE"="quartz")

setHook(packageEvent("grDevices", "onLoad"),
    function(...) grDevices::quartz.options(dpi=220, width=5, height=4, pointsize=8))
