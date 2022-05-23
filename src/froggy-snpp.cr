require "option_parser"
require "socket"
require "readline"

VERSION = "0.1.0"
DATE = "2022-05-23"

port = 444
host = "localhost"
pager_id = ""
username = ""
password = ""
message = ""
verbose = false


OptionParser.parse do |parser|
  parser.banner = "Froggy SNPP -- For All Your Paging Needs!"

  parser.on "-v", "--version", "Prints the version of this program." do
    puts "Froggy SNPP Client"
    puts "v#{VERSION} (#{DATE})"
    puts "built using Crystal v#{Crystal::VERSION}"
    exit
  end
  parser.on "-h", "--help", "Prints help. You made it this far!" do
    puts parser
    exit
  end

  parser.on "-p PORT", "--port PORT", "Sets the port number (default: 444)." do |user_port|
    port = user_port
  end
  parser.on "-s HOSTNAME", "--server HOSTNAME", "Sets the SNPP server (default: localhost)." do |hostname|
    host = hostname
  end
  parser.on "-n ID", "--pager-number ID", "The ID of the device to page (prompted for if unset)." do |id|
    pager_id = id
  end
  parser.on "-u USER", "--user USER", "Username to authenticate with (optional)." do |user|
    username = user
  end
  parser.on "-P PASSWORD", "--password PASSWORD", "Prompted for if unset while -u is set. Ignored without -u." do |pass|
    password = pass
  end
  parser.on "-m MESSAGE", "--message MESSAGE", "The message to send! (Prompted for if unset, 160 character limit.)" do |text|
    message = text.chomp
  end
  parser.on "-V", "--verbose", "Prints all server responses when set." do
    verbose = true
  end

  parser.missing_option do |option_flag|
    STDERR.puts "Error: #{option_flag} requires an argument!"
    STDERR.puts parser
    exit 1
  end
  parser.invalid_option do |option_flag|
    STDERR.puts "Error: #{option_flag} is not a known option."
    STDERR.puts parser
    exit 1
  end
end


# Initialize connection to the server.
begin
  client = TCPSocket.new host, port
rescue e : Socket::ConnectError
  STDERR.puts e.message
  STDERR.puts "Run 'froggy-snpp -h' for help."
  exit 1
end
# From this point onward, gracefully tell the server we are leaving on ctrl + c.
Signal::INT.trap do
  client << "QUIT\n"
  response = client.gets
  puts response
  client.close
  exit 130
end
# Ensure the server is ready to accept commands.
response = client.gets.as(String)
if response[0] != '2'
  STDERR.puts response
  exit 1
end
verbose ? puts response : nil

# Log in if a username has been set.
if username != ""
  should_proceed = false
  if password != ""
    client << "LOGI #{username} #{password}\n"
    response = client.gets.as(String)
    should_proceed = response[0] == '2' ? true : false
    verbose || !should_proceed ? puts response : nil
  end
  while !should_proceed
    STDIN.noecho do
      print "Enter the password for #{username} (hidden): "
      password = Readline.readline.as(String).chomp
    end
    client << "LOGI #{username} #{password}\n"
    response = client.gets.as(String)
    should_proceed = response[0] == '2' ? true : false
    verbose || !should_proceed ? puts response : nil
  end
end

# Ensure a valid pager ID is set.
should_proceed = false
if pager_id != ""
  client << "PAGE #{pager_id}\n"
  response = client.gets.as(String)
  should_proceed = response[0] == '2' ? true : false
  verbose || !should_proceed ? puts response : nil
end
while !should_proceed
  print "Enter the ID of the device to page: "
  pager_id = Readline.readline.as(String).chomp
  client << "PAGE #{pager_id}\n"
  response = client.gets.as(String)
  should_proceed = response[0] == '2' ? true : false
  verbose || !should_proceed ? puts response : nil
end

# Ensure a valid message is set.
should_proceed = false
if message.size > 0 && message.size <= 160
  message = message.gsub /\n|\r/, ' '
  client << "MESS #{message}\n"
  response = client.gets.as(String)
  should_proceed = response[0] == '2' ? true : false
  verbose || !should_proceed ? puts response : nil
end
while !should_proceed
  message.size > 0 ? (puts "Message invalid! Is it under 160 characters?") : nil
  print "Enter your message: "
  message = Readline.readline.as(String).chomp
  if message.size > 0 && message.size <= 160
    message = message.gsub /\n|\r/, ' '
    client << "MESS #{message}\n"
    response = client.gets.as(String)
    should_proceed = response[0] == '2' ? true : false
    verbose || !should_proceed ? puts response : nil
  end
end

# Send the message and quit.
client << "SEND\n"
response = client.gets
puts response

client << "QUIT\n"
response = client.gets
verbose ? puts response : nil
client.close
