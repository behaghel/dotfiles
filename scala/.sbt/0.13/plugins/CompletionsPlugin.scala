import sbt._
import Keys._
import sbt.complete._
import Parsers._

object CompletionsPlugin extends Plugin {
  override lazy val settings = Seq(commands += completions)

  lazy val completions = Command.make("completions") { state =>
    val notQuoted = (NotQuoted ~ Parsers.any.*) map {case (nq, s) => (nq +: s).mkString}
    val quotedOrUnquotedSingleArgument = Space ~> (StringVerbatim | StringEscapable | notQuoted)

    Parser.token(quotedOrUnquotedSingleArgument ?? "" examples("", " ")) map { input =>
      () => {
        Parser.completions(state.combinedParser, input, 1).get map {
          c => if (c.isEmpty) input else input + c.append
        } foreach { c =>
          println("[completions] " + c.replaceAll("\n", " "))
        }
        state
      }
    }
  }
}
