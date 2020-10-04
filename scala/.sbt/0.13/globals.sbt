// import sbt._
// import Defaults._

// needed to have the Completions plugin to work
// (this enables completion eg in sbt-mode in emacs)
// deactivated as it conflicts json4s 2.11 as it imports version for 2.10...
// sbtPlugin := true

resolvers += Classpaths.typesafeResolver

resolvers += "Sonatype snapshots" at "http://oss.sonatype.org/content/repositories/snapshots"

resolvers += "Sonatype releases" at "http://oss.sonatype.org/content/repositories/releases"

// Ctrl-C kill the pending task in sbt but not sbt itself
cancelable in Global := true

// clear the screen each time a task is auto-triggered (~task)
triggeredMessage in ThisBuild := Watched.clearWhenTriggered

import de.heikoseeberger.sbtfresh.FreshPlugin.autoImport._
freshAuthor       := "Hubert Behaghel" // "user.name" sys prop or "default" by default
freshOrganization := "org.behaghel"    // Build organization – "default" by default
freshSetUpGit     := true              // Initialize a Git repo and create an initial commit – true by default
freshLicense      := "mit"             // License kind, see avalable options below – `apache` by default
// sbt fresh name=<project-name>
