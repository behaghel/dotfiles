import sbt._
import Defaults._

resolvers += Classpaths.typesafeResolver

libraryDependencies <+= (sbtVersion in update, scalaVersion) { (sbtV, scalaV) => 
  sbtV match {
    case "0.11.2" =>
      sbtPluginExtra("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "2.0.0", sbtV, scalaV)
    case _ =>
      sbtPluginExtra("com.typesafe.sbteclipse" % "sbteclipse" % "1.4.0", sbtV, scalaV)
  }
}

