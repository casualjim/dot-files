import sys, socket, string, vim
from subprocess import Popen, PIPE, STDOUT

def vimQuote(s):
  return '"%s"' % s.replace('"', '\\"').replace("\n", "\\n")

def debug(s):
  vim.command("echoe %s" % vimQuote(s))

doDebug = False

class CodeFellowConnection():

  def logfile(self):
    logfile = vim.eval('tempname()')
    vim.command('let g:codefellow_server_logfile = '+vimQuote(logfile))
    vim.command('call codefellow#Echo("server log : g:codefellow_server_logfile=".'+vimQuote(logfile)+")")
    return open(logfile, 'w')


class SocketConnection(CodeFellowConnection):

    def __init__(self, port_or_auto, start_server):
      self.port = port_or_auto
      if start_server == "1":
        # TODO: Wait until server is listening. Probably you'll get one Exception
        log = self.logfile()
        cmd = vim.eval('g:codefellow_server_cmd')
        if doDebug:
          debug("starting server, cmdline: "+(" ".join(cmd)))
        self.process = Popen(cmd, \
          shell = False, bufsize = 1, stdin = PIPE, stdout = log, stderr = STDOUT)

    def sendMessage(self,message):
      s = socket.socket()
      s.connect(("localhost", int(self.port)))
      s.sendall(message)

      counter=1
      # read until server closes connection
      data = ""
      while 1:
          tmp = s.recv(1024)
          if not tmp:
              break
          data += tmp
          counter +=1
          if counter > 100000:
            # there is one case where the server outputs newlines only..
            raise "something must have gone wrong. Got too much data"
      return data


# stdin/out requires Vim to launch server
# TODO: think about reconnect
class StdinOutConnection(CodeFellowConnection):
    def __init__(self):
      log = self.logfile()
      self.log = self.logfile()
      cmd = vim.eval('g:codefellow_server_cmd')+["-"]
      if doDebug:
        debug("starting server, cmdline: "+(" ".join(cmd)))
      self.process = Popen(cmd, \
            shell = False, bufsize = 1, stdin = PIPE, stdout = PIPE, stderr = self.log)
      self.sbt_o = self.process.stdout
      self.sbt_i = self.process.stdin

    def sendMessage(self, message):
      if doDebug:
        debug("sending msg"+ message)
      self.sbt_i.write(message+"\n")
      self.sbt_i.flush()
      return self.readMessage()

    def readMessage(self):
      result = []
      while True:
        if doDebug:
          debug("waiting for line")
        line = self.sbt_o.readline()
        if doDebug:
          debug("got line"+line)

        # removing trailing \n
        line = line[:-1]

        # only accept lines starting with server:
        if line[0:len("server:")] != "server:":
          if doDebug:
            debug("suspcious line "+line)
          self.log.write(line+"\n")
          self.log.flush()
          continue
        line = line[len("server:"):]

        if line == "ENDREPLY":
          return "\n".join(result)

        result.append(line)
