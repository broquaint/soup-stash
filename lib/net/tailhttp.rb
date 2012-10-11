require 'net/http'
require 'uri'

class Net::TailHTTP
  def self.for_uri(u, wait = 2)
    uri      = URI.parse(u)
    http     = Net::HTTP.new(uri.host, uri.port)
    head_req = Net::HTTP::Head.new(uri.to_s)

    for_a_bit = wait
    offset    = 0
    while true
      head_response = http.request(head_req)

      size_now = head_response.content_length
      if size_now == offset
        sleep for_a_bit
        next
      end

      get_request = Net::HTTP::Get.new(uri.to_s)
      get_request.initialize_http_header('Range' => "bytes=#{offset}-#{size_now}")

      get_response = http.request(get_request)

      offset += get_response.content_length

      yield get_response

#      puts "\nNow at #{offset} for #{uri.to_s}"

      sleep for_a_bit
    end
  end
end
