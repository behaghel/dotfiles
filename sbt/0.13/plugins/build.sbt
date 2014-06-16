import sbt._
import Defaults._

// needed to have the Completions plugin to work 
// (this enables completion eg in sbt-mode in emacs)
sbtPlugin := true

resolvers += Classpaths.typesafeResolver

resolvers += "Sonatype snapshots" at "http://oss.sonatype.org/content/repositories/snapshots"

resolvers += "Sonatype releases" at "http://oss.sonatype.org/content/repositories/releases"

//addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.0.0")

addSbtPlugin("org.ensime" % "ensime-sbt-cmd" % "0.1.2")
