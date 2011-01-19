module FileBrowser
 def browse(root)
   queue = Array.new.push(root)
   while !queue.empty?
     filename = queue.pop
     if File.file?(filename)
       yield(filename)
     else
       Dir.new(filename).each do |child|
         unless ['..', '.','.svn', '.git'].include? child
           queue.push(filename + "/" + child)
         end
       end
     end
   end
 end
end

class HeadersCheck
 EXT = ['mxml', 'as']

 include FileBrowser

 def check_files(dir, dry_run)
   count = 0
   browse(dir) do |filename|
     if /\.#{EXT.join('$|\.')}$/ =~ filename
       match = nil
       f = File.new(filename)
       # Checking for the Apache header in the 4 first lines
       4.times do
         match ||= (/Copyright 2011 John Moore, Scott Gilroy/ =~
f.readline) rescue nil
           #puts("File #{filename} too short to check.")
       end
       f.close
       unless match
         if dry_run
           puts "Missing header in #{filename}"
         else
           add_header(filename)
         end
         count += 1
       end
     end
   end
   if dry_run
     puts "#{count} files don't have an Apache license header."
   else
     puts "#{count} files have been changed to include the Apache license
header."
   end
 end

 def add_header(filename)
   # Extracting file extension
   ext = /\.([^\.]*)$/.match(filename[1..-1])[1]
   header = HEADERS[ext]
   content = File.new(filename, 'r').read
   if content[0..4] == '<?xml'
     # If the file has a xml header, the license needs to be appended after
     content = content[0..content.index("\n")] + header + content[(
content.index("\n") + 1)..-1]
   else
     content = header + content
   end
   File.new(filename, 'w').write(content)
 end

end

JAVA_HEADER = <<JAVA
/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
JAVA

MXML_HEADER = <<XML
<!--
 ~ Copyright 2011 John Moore, Scott Gilroy
 ~
 ~ This file is part of CollaboRhythm.
 ~
 ~ CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 ~
 ~ CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 ~
 ~ You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
 -->
XML

HEADERS = {
 'java' => JAVA_HEADER,
 'as' => JAVA_HEADER,
 'cpp' => JAVA_HEADER,
 'mxml' => MXML_HEADER,
 'bpel' => MXML_HEADER,
 'wsdl' => MXML_HEADER
}

if ['-h', '--help', 'help'].include? ARGV[0]
 puts "Scans the current directory for files with missing Apache "
 puts "license headers."
 puts "   ruby check_license_headers.rb      # list files"
 puts "   ruby check_license_headers.rb add  # add headers automatically"
else
 HeadersCheck.new.check_files('.', ARGV[0] != 'add')
end