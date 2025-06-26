module Puppet::Parser::Functions
  newfunction(:file_exists, :type => :rvalue) do |args|
    raise(Puppet::ParseError, 'file_exists(): Wrong number of arguments') if args.empty?
    file = File.expand_path(args[0])
    File.exist?(file)
  end
end
