import sbt._
import Defaults._

resolvers += Classpaths.typesafeResolver

resolvers += "Sonatype snapshots" at "http://oss.sonatype.org/content/repositories/snapshots"

resolvers += "Sonatype releases" at "http://oss.sonatype.org/content/repositories/releases"

//addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.0.0")

addSbtPlugin("org.ensime" % "ensime-sbt-cmd" % "0.1.2")
