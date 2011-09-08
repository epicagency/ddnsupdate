module DDNSUpdate
  require 'open3'
  require 'digest/md5'
  require 'base64'
  require 'socket'
  require 'net/http'
  require 'uri'

  class UpdateError < StandardError; end

  def self.keygen(input)
    Base64.encode64(Digest::MD5.hexdigest(input.downcase))
  end

  def self.determine_soa(zone)
    current = zone.gsub(/\.$/, "")
    soa = nil
    while soa.nil? and !current.empty?
      soa = %x{dig -t SOA #{current} +noquestion +nostats +nocmd +noqr +nocomments +noadditional +nottlid}
      if not soa.nil?
        #Split lines into an array, filtering out comments and blanks
        soa = soa.split("\n").delete_if { |el| el.start_with?(";") || el.empty? }
        #Split remaining line into whitespace delimited fields
        if not soa.empty?
          soa = soa[0].split(/\s/)
          #Find the field we actually want, stripping the trailing dot
          soa = soa[soa.index("SOA") + 1].gsub(/\.$/, "")
        else
          soa = nil
        end
      end
      current.sub! /^.*?\./, ""
    end
    return soa
  end

  def self.determine_current_ip(zone, soa=nil)
    soa = determine_soa(zone) unless !soa.nil?
    %x{dig @#{soa} #{zone} A +short }
  end

  def self.determine_local_ip
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily

    UDPSocket.open do |s|
      s.connect '64.233.187.99', 1
      s.addr.last
    end
  ensure
      Socket.do_not_reverse_lookup = orig
  end

  def self.determine_remote_ip
    Net::HTTP.get(URI.parse('http://www.whatismyip.org/'))
  end

  def self.update(zone, ip, key, wild = false)
    soa         = determine_soa(zone)
    raise UpdateError, "can't find SOA for #{zone}" if soa.nil?
    curip       = determine_current_ip(zone, soa)

    if curip != ip
      delete_seq  = <<-";"
                    server #{soa}
                    key #{zone}. #{key}
                    prereq yxdomain #{zone}.
                    update delete #{zone}. A
                    ;
      delete_seq += "                    update delete *.#{zone}. A\n" if wild
      delete_seq += "                    send\n"

      create_seq  = <<-";"
                    server #{soa}
                    key #{zone}. #{key}
                    prereq nxdomain #{zone}.
                    update add #{zone}. 300 A #{ip}
                    ;
      create_seq += "                    update add *.#{zone}. 300 A #{ip}\n" if wild
      create_seq += "                    send\n"

      Open3.popen3("nsupdate") do |stdin, stdout, stderr|
        stdin << delete_seq << create_seq
        stdin.close_write
        err = stderr.read
        raise UpdateError, err unless err.empty?
      end
      true
    else
      false
    end
  end
end
