#!/usr/bin/ruby

# reports a passive check to nagios using nsca client script

# Load Balancer is running in BACKUP state\" | /usr/sbin/send_nsca -H 171.64.144.35 -p 5667"

# notify_nagios -H NAGIOS_HOST [-p PORT] -S STATE -s SERVICENAME -m MESSAGE

require 'optparse'
require 'ostruct'
require 'pp'
require 'socket'

#
# returns a structure describing the options passed
# 
class NagiosPassiveCheckParser
  def self.parse(args)
    
   states = { "OK" => "0", "WARNING" => "1",  "CRITICAL" => "2", "UNKNOWN" => "3" }
   messages = { "master" => "Load Balancer is running in MASTER state",
                "backup" => "Load Balancer is running in BACKUP state",
                "fault"  => "Load Balancer is *DOWN*. Please check" }
       
   # command line options will be collected in *options*
   options = OpenStruct.new
   options.port = 5667 # default port for nsca
   opts = OptionParser.new do |opts|
     opts.banner = "Usage: notify_nagios"
     
     # mandatory arguments
     opts.on("-H","--host NAGIOS_IP",
             "Require the IP address of the server running Nagios") do |host|
            options.host = host
     end

     opts.on("-s", "--service SERVICE_NAME", 
             "Name of the target service on Nagios") do |service|
            options.service = service
     end
   
     opts.on("-p", "--port NSCA_SERVER_PORT", 
             "Set the listening port for the NCSA daemon. Defaults to 5667") do |port|
            options.port = port
     end
        
     opts.on("-S","--state STATE", [:OK, :WARNING, :CRITICAL, :UNKNOWN],
             "Set the state of the service (OK, WARNING, CRITICAL, UNKNOWN)") do |state|
            options.state = states["#{state}"]
     end
     
     opts.on("-m","--message MESSAGE",
             "Send a predefined or custom message to Nagios informing about the wished status (master, backup, fault).") do |msg|

             # allows custom messages
             if messages["#{msg}"].nil?
               options.message = msg.to_s
             else 
               options.message = messages["#{msg}"]
             end  
     end
     
     opts.on("-h", "--help", "Show this message") do 
        puts opts
        exit
     end
     
   end
    
    opts.parse!(args)

    # raise required arguments to make sure all the required arguments were satisfied
    raise OptionParser::MissingArgument if options.host.nil?
    raise OptionParser::MissingArgument if options.service.nil?
    
    options # returns the struct created        
  end # parse()
  
end # class NagiosOptParse

# parse cmd line options
options = NagiosPassiveCheckParser.parse(ARGV)

# manage required packages
raise "send_nsca was not found." unless File.executable?("/usr/sbin/send_nsca")

# send the passive notification
Kernel.system("echo \"#{Socket.gethostname};#{options.service};#{options.state};#{options.message}\" | send_nsca -H #{options.host} -p #{options.port} -d ';'")

exit 
