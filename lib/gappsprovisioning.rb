$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
require 'net/https'
require 'cgi'
require 'rexml/document'

require 'gappsprovisioning/connection'
require 'gappsprovisioning/exceptions'
require 'gappsprovisioning/provisioningapi'

module GAppsProvisioning
  VERSION = '0.1.0'
end
