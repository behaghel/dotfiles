// deactivate it if you can't resolve or cross version conflict on jaw-parser
libraryDependencies += "com.lihaoyi" % "ammonite" % "0.7.7" % "test" cross CrossVersion.full

initialCommands in (Test, console) := """ammonite.Main().run()"""

