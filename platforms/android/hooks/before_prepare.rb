#!/usr/bin/env ruby

require 'pathname'
require 'cordova_plugin_fabric'

def modify_java(main_file, kits)
    return if main_file.nil? || tools.empty?

    file_tmp = "#{main_file}.tmp"

    File.open(main_file, 'r') { |src|
        File.open(file_tmp, 'w') { |dst|
            src.each_line { |line|
                dst.puts line
                add_line = lambda { |text|
                    dst.puts "#{line.match(/^[\s]*/)[0]}#{text}"
                }
                if line =~ /super.onCreate/
                    add_line.call "try {"
                    add_line.call "    io.fabric.sdk.android.Fabric.with(this, #{kits.instances.join(', ')});"
                    add_line.call "} catch (Exception ex) { throw new RuntimeException(ex); }"
                end
            }
        }
    }
    File.rename(file_tmp, main_file)
end

$PROJECT_DIR = Pathname.pwd.realpath
$PLATFORM_DIR = $PROJECT_DIR/'platforms'/'android'

modify_java Pathname.glob($PLATFORM_DIR/'src'/'**'/'MainActivity.java').first, Fabric::Kits.new('android', $PROJECT_DIR)
