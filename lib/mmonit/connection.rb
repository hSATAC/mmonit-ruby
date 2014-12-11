require 'net/http'
require 'net/https'
require 'json'

module MMonit
	class Connection
		attr_reader :http, :address, :port, :ssl, :username, :useragent, :headers
		attr_writer :password

		def initialize(options = {})
			@ssl = options[:ssl] || false
			@address = options[:address]
			options[:port] ||= @ssl ? '8443' : '8080'
			@port = options[:port]
			@username = options[:username]
			@password = options[:password]
			options[:useragent] ||= "MMonit-Ruby/#{MMonit::VERSION}"
			@useragent = options[:useragent]
			@headers = {
				'Host' => @address,
				'Referer' => "#{@url}/index.csp",
				'Content-Type' => 'application/x-www-form-urlencoded',
				'User-Agent' => @useragent,
				'Connection' => 'keepalive'
			}
		end

		def connect
			@http = Net::HTTP.new(@address, @port)

			if @ssl
				@http.use_ssl = true
				@http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			end

			@headers['Cookie'] = @http.get('/index.csp').response['set-cookie'].split(';').first
			self.login
		end

		def login
			self.request('/z_security_check', "z_username=#{@username}&z_password=#{@password}").code.to_i == 302
		end

    # TODO: filter arguments
		def status_overview
			JSON.parse(self.get('/status/hosts/list').body)['records']
		end

		# TODO: get by id
		def status(id)
    end

		def status_summary
			JSON.parse(self.get('/status/hosts/summary').body)
		end

		def hosts
			JSON.parse(self.get('/admin/hosts/list').body)['records']
		end

		#def users
			#JSON.parse(self.request('/json/admin/users/list').body)
		#end

		#def alerts
			#JSON.parse(self.request('/json/admin/alerts/list').body)
		#end

		#def events
			#JSON.parse(self.request('/json/events/list').body)['records']
		#end

		####  topography and reports are disabled until I figure out their new equivalent in M/Monit
		# def topography
		# 	JSON.parse(self.request('/json/status/topography').body)
		# end

		# def reports(hostid=nil)
		# 	body = String.new
		# 	body = "hostid=#{hostid.to_s}" if hostid
		# 	JSON.parse(self.request('/json/reports/overview', body).body)
		# end

		def find_host_by_hostname(fqdn)
			host = self.hosts.select{ |h| h['hostname'] == fqdn }
			host.empty? ? nil : host.first
		end

		# another option:  /admin/hosts/json/get?id=####
		def get_host_details(id)
			JSON.parse(self.get("/admin/hosts/get?id=#{id}").body) rescue nil
		end

		def delete_host(id)
			self.request("/admin/hosts/delete?id=#{id}")
		end

		def request(path, body="", headers = {})
			self.connect unless @http.is_a?(Net::HTTP)
			@http.post(path, body, @headers.merge(headers))
		end

		def get(path, headers = {})
			self.connect unless @http.is_a?(Net::HTTP)
			@http.get(path, @headers.merge(headers))
    end
	end
end
