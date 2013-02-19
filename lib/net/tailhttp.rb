require 'net/http'
require 'uri'

class Net::TailHTTP
  def self.for_uri(opts)
    uri      = URI.parse(opts[:uri])
    http     = Net::HTTP.new(uri.host, uri.port)
    head_req = Net::HTTP::Head.new(uri.to_s)

    offset    = opts[:offset] || 0
    for_a_bit = opts[:wait]   || 60
    while true
      begin
        head_response = http.request(head_req)
      rescue Errno::ETIMEDOUT
        sleep for_a_bit
        next
      end

      size_now = head_response.content_length
      if size_now == offset
        sleep for_a_bit
        next
      end

      get_request = Net::HTTP::Get.new(uri.to_s)
      get_request.initialize_http_header('Range' => "bytes=#{offset}-#{size_now}")

      begin
        get_response = http.request(get_request)
      rescue Errno::ETIMEDOUT
        sleep for_a_bit
        next
      end

      offset += get_response.content_length

      yield get_response, offset

      puts "\n[#{Time.now}] Now at #{offset} for #{uri.to_s}" if opts[:verbose]

      sleep for_a_bit
    end
  end
end
