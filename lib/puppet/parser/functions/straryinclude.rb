Puppet::Parser::Functions::newfunction(:straryinclude,
  :type => :rvalue,
  :doc => 'finds whether the argument includes? some value') do |args|
  if args[0].respond_to?(:"include?")
    return args[0].include? args[1]
  end
  false
end