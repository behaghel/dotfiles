var child_process = require('child_process');

function getStdout(cmd) {
  var stdout = child_process.execSync(cmd);
  return stdout.toString().trim();
}

exports.host = "imap.gmail.com";
exports.port = 993;
exports.tls = true;
exports.tlsOptions = { "rejectUnauthorized": false };
exports.username = "behaghel@gmail.com";
exports.password = getStdout("pass sysadmin/chromebook/acer-spin-13/gmail-mu4e");
exports.onNewMail = "mbsync gmail";
exports.onNewMailPost = { mail: "~/.local/bin/emacsclient  -e '(mu4e-update-index)'" };
exports.boxes = ["INBOX"];
