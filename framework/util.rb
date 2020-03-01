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


def generate_location_pxt(idd, ddy_path, site_path)
  location_file = File.open(site_path, "w")

  if (File.exists?(ddy_path))
    input_file = OpenStudio::InputFile.open(idd, ddy_path)
  else
    puts "File not found: #{ddy_path}"
    exit
  end

  site_locations = input_file.find_objects_by_class_name("Site:Location").to_a  # Kind of annoying this is a Collection, not an Array

  if (site_locations.empty?)
    puts "Error: could not find Site:Location object"
    exit
  else
    location_file.puts(site_locations.first.to_idf)
  end

  all_design_days = input_file.find_objects_by_class_name("SizingPeriod:DesignDay").to_a  # Kind of annoying this is a Collection, not an Array

  # Better to pass in array of requested days, e.g., ["Ann Htg 99.6% Condns DB"), "Ann Clg .4% Condns DB=>MWB"]
  selected_design_days = all_design_days.find_all { |dd| dd.name.include?("Ann Htg 99.6% Condns DB") or dd.name.include?("Ann Clg .4% Condns DB=>MWB") }  # or "Ann Htg 99% Condns DB" and "Ann Clg 1% Condns DB=>MWB"

  if (selected_design_days.length < 2)
    puts "Warning:  Could not find requested design days; including all design days"
    puts ddy_path
    selected_design_days = all_design_days
  end

  # Write design days to location file.
  selected_design_days.each { |dd| location_file.puts(dd.to_idf) }


# 'CorrelationFromWeatherFile' is available starting in EP 9.0.

# Does this work for design-day only runs?
# Seems to work for annual.
  location_file.puts("\n\nSite:WaterMainsTemperature,\n  CorrelationFromWeatherFile;\n")

  daylight_saving_time = input_file.find_objects_by_class_name("RunPeriodControl:DaylightSavingTime").to_a
  if (not daylight_saving_time.empty?)
    location_file.puts
    location_file.puts(daylight_saving_time.first.to_idf)
  end

  location_file.close
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
