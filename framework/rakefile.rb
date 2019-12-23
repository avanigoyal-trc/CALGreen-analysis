# IMPORTANT: To run any of the tasks in this file, use "modelkit rake <task>"!

if (not defined?(Modelkit))
  begin
    require("modelkit")
  rescue LoadError => exception
    args = ARGV.join(" ")
    puts exception
    puts "NOTE: This rakefile requires the Modelkit library. Make sure that you have the\nModelkit gem installed in your local Rubygems environment, or try running the\nrakefile using your stand-alone installation of Modelkit by typing:\n  modelkit rake #{args}"
    exit
  end
end


require("modelkit/config")
require("modelkit/parametrics/template")
require("modelkit/energyplus")

require("fileutils")
require("csv")
require_relative("util")


root_dir = File.expand_path(__dir__)
runs_dir = "#{root_dir}/runs"

CONFIG = Modelkit::Config.new("#{root_dir}/.modelkit-config")

cbecc_com_path = CONFIG["cbecc-com-path"]
templates_dir = "#{root_dir}/templates/cbecc-com"
global_pxv_path = "#{root_dir}/global.pxv"


task :default do
  puts "There is no default task defined. To see the allowed list of tasks, type:"
  puts "  modelkit rake --tasks"
end


desc "Clean/delete previous runs"
task :clean, [:analysis] do |task, args|
  analysis_name = args[:analysis]
  if (analysis_name.nil?)
    puts "You must specify the name of the analysis. For example:\n"
    puts "  #{program_name} #{task.name}[hvac]"
    exit
  end

  puts "Cleaning runs for: #{analysis_name}"

  runs_dir = "#{root_dir}/analysis/#{analysis_name}/runs"
  FileUtils.rm_rf(runs_dir)
  FileUtils.mkdir_p(runs_dir)
  puts "Clean completed."
end


desc "Generate pxv files for cases"
task :cases, [:analysis] do |task, args|
  analysis_name = args[:analysis]
  if (analysis_name.nil?)
    puts "You must specify the name of the analysis. For example:\n"
    puts "  #{program_name} #{task.name}[hvac]"
    exit
  end

  analysis_dir = "#{root_dir}/analysis/#{analysis_name}"
  cases_path = "#{analysis_dir}/cases.csv"
  if (not File.exist?(cases_path))
    puts "File not found (cases.csv) at expected path: #{cases_path}"
    exit
  end

  puts "Generating cases for: #{analysis_name}"

  cases_csv = CSV.read(cases_path, :headers=>true)
  cases_csv.each do |case_row|

    # Parse the row for this case.
    case_pxv = ""
    case_name = nil  # Have to do this so result stays in scope
    prototype_name = nil
    baseline_name = nil
    case_row.each do |header, value|
      if (header == "case")
        case_name = value

      elsif (header == "prototype")
        prototype_name = value

      elsif (header == "baseline")
        baseline_name = value

      elsif (match = header.match(/^\s*:(\w*)/))
        variable_name = match.captures.first
        if (value)
          case_pxv << ":#{variable_name}=>#{value_from_string(value)},\n"
        end
      end
    end

    baseline_path = "#{root_dir}/baselines/#{prototype_name}/#{baseline_name}.csv"
    if (not File.exist?(baseline_path))
      puts "File not found (#{baseline_name}.csv) at expected path: #{baseline_path}"
      exit
    end

    baseline_csv = CSV.read(baseline_path, :headers=>true)
    baseline_csv.each do |baseline_row|

      # Parse the row for this baseline.
      baseline_pxv = ""
      climate_name = nil  # Have to do this so result stays in scope
      baseline_row.each do |header, value|
        if (header == "climate")
          climate_name = value

        elsif (match = header.match(/^\s*:(\w*)/))
          variable_name = match.captures.first
          if (value)
            baseline_pxv << ":#{variable_name}=>#{value_from_string(value)},\n"
          end
        end
      end

      case_dir = "#{analysis_dir}/runs/#{case_name}/#{climate_name}"
      puts "  #{case_name}/#{climate_name}"
      FileUtils.mkdir_p(case_dir)
      File.write("#{case_dir}/prototype.txt", prototype_name)
      File.write("#{case_dir}/case.pxv", case_pxv)
      File.write("#{case_dir}/baseline.pxv", baseline_pxv)
    end
  end

end


desc "Compose the simulation runs"
task :compose, [:analysis] do |task, args|
  analysis_name = args[:analysis]
  if (analysis_name.nil?)
    puts "You must specify the name of the analysis. For example:\n"
    puts "  #{program_name} #{task.name}[hvac]"
    exit
  end

  puts "Composing cases for: #{analysis_name}"

  analysis_dir = "#{root_dir}/analysis/#{analysis_name}"

  case_dirs = Dir.glob("#{analysis_dir}/runs/**/cz*").sort
  case_dirs.each do |case_dir|
    baseline_pxv_path = "#{case_dir}/baseline.pxv"
    case_pxv_path = "#{case_dir}/case.pxv"
    out_path = "#{case_dir}/instance.cibd19"

    prototype_name = File.read("#{case_dir}/prototype.txt")
    root_path = "#{root_dir}/prototypes/cbecc-com/#{prototype_name}/root.pxt"

    puts "  #{case_dir}"
    Modelkit::Parametrics.compose(root_path,
      :annotate => true,
      #:indent => "    ",  # Turn off indent because it adds blank lines that CBECC does not like
      :"esc-line" => "// ",
      :dirs => templates_dir,
      :files => "#{case_pxv_path};#{baseline_pxv_path};#{global_pxv_path}",
      :output => out_path)
  end

end


desc "Run simulations"
task :run, [:analysis] do |task, args|
  analysis_name = args[:analysis]
  if (analysis_name.nil?)
    puts "You must specify the name of the analysis. For example:\n"
    puts "  #{program_name} #{task.name}[hvac]"
    exit
  end

  puts "Running cases for: #{analysis_name}"

  analysis_dir = "#{root_dir}/analysis/#{analysis_name}"

  paths = Dir.glob("#{analysis_dir}/runs/**/instance.cibd19").sort
  paths.each do |path|
    puts "  #{File.dirname(path)}"
    system("CALL \"#{cbecc_com_path}\" -pa -nogui \"#{path}\"")
  end
end


desc "Aggregate the simulation results"
task :results, [:analysis] do |task, args|
  analysis_name = args[:analysis]
  if (analysis_name.nil?)
    puts "You must specify the name of the analysis. For example:\n"
    puts "  #{program_name} #{task.name}[hvac]"
    exit
  end

  analysis_dir = "#{root_dir}/analysis/#{analysis_name}"
  header = File.read("#{root_dir}/results-header.csv")

  File.open("#{analysis_dir}/results.csv", "w") do |line|
    line.puts(header)  # Write the standard header

    instance_log_paths = Dir.glob("#{analysis_dir}/runs/**/instance.log.csv").sort
    instance_log_paths.each do |path|
      case_dir = File.dirname(path)
      dir_name = "#{File.basename(File.dirname(case_dir))}/#{File.basename(case_dir)}"

      instance_log_csv = File.readlines(path)  # Read entire instance.log.csv file into an Array
      line.puts("#{dir_name},#{instance_log_csv.last}")
    end
  end
end
