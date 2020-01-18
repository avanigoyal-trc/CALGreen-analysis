# Copyright (c) 2019 Big Ladder Software LLC. All rights reserved.
# See the file "license.txt" for additional terms and conditions.


# Convert a string (e.g., read from CSV) into a value.
def value_from_string(string)
  string = string.to_s  # Make sure value is really a String! otherwise fails
  if (true if Integer(string) rescue false)
    value = string.to_i
  elsif (true if Float(string) rescue false)
    value = string.to_f
  elsif (string == "nil")
    value = "nil"
  elsif (string.downcase == "false")
    value = false
  elsif (string.downcase == "true")
    value = true
  elsif (match = string.match(/(\d*\.?\d*)\s*\|\s*["'](.*)["']/))  # This is close but not perfect
    number, units = match.captures
    value = "#{number.to_f}|\"#{units}\""
  else
    value = "\"#{string}\""
  end
  return(value)
end


# Support for running simulations in parallel.
# Should move into Modelkit somewhere.
require_relative("work_queue")
require("open3")
require("set")

$child_pids = Set.new  # Global tracking of child PIDs

# Return PID?
def run_process(command, dir)
  # ':chdir => dir' will force the process to run in the specified directory.
  # NOTE: Separate processes are required to make the EnergyPlus runs thread safe!
  Open3.popen3(command) do |stdin, stdout, stderr, thread|
    $child_pids.add(thread.pid)
    # This might work with just an instance variable or similar.

    stdin.close  # All input already sent with command

    file_out = File.open("#{dir}/stdout", "w")
    file_err = File.open("#{dir}/stderr", "w")

    while (line = stdout.gets)
      file_out.puts(line)
      #@proc_out.call(line) if (@proc_out)
    end

    # This is probably not right.
    while (line = stderr.gets)
      file_err.puts(line)
      #@proc_err.call(line) if (@proc_err)
    end

    stdout.close
    stderr.close

    file_out.close
    file_err.close

    #print "Completed: #{File.basename(dir)}\n"
    $child_pids.delete(thread.pid)
  end
end
