def capture_stdout
  old_stdout = $stdout.dup
  rd, wr = IO.method(:pipe).arity.zero? ? IO.pipe : IO.pipe("BINARY")
  $stdout = wr
  yield
  wr.close
  rd.read
ensure
  $stdout = old_stdout
end

def capture_stderr
  old_stderr = $stderr.dup
  rd, wr = IO.method(:pipe).arity.zero? ? IO.pipe : IO.pipe("BINARY")
  $stderr = wr
  yield
  wr.close
  rd.read
ensure
  $stderr = old_stderr
end
