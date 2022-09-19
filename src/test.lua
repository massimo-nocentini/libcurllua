
local curl = require 'curl'

local function G (cu)

	local code

	code = curl.curl_easy_setopt_url(cu, 'https://www.google.com')
	assert(code == 0)

	code = curl.curl_easy_setopt_verbose(cu, true)
	assert(code == 0)

	code = curl.curl_easy_setopt_cainfo(cu, 'curl-ca-bundle.crt')
	assert(code == 0)

	code = curl.curl_easy_perform(cu)
	assert(code == 0)

end

local function apptivegrid_plain (cu)

	curl.with_http_header_do({ 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		function (headers) 
			
			curl.curl_easy_setopt {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
				verbose = true,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
				httpheader = headers,
			} (cu)

			code = curl.curl_easy_perform(cu)
			assert(code == 0)

		end)

end

local function apptivegrid (cu)

	curl.with_http_header_do({ 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		function (headers) 
			
			curl.curl_easy_setopt {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
				verbose = true,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
				httpheader = headers,
			} (cu)

			code = curl.curl_easy_setopt_writefunction(cu, nil)
			assert(code == 0)

			code, memory = curl.curl_easy_setopt_writedata(cu, nil)
			assert(code == 0)

			code = curl.curl_easy_perform(cu)
			assert(code == 0)

			local response = curl.curl_easy_getopt_writedata(memory)
			curl.libc_free(memory)
			
			print('\n'..response)
		end)

end

local function apptivegrid1 (cu)

	curl.with_http_header_do({ 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		function (headers) 
			
			curl.curl_easy_setopt {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
				verbose = true,
				header = true,
				cainfo = 'curl-ca-bundle.crt',
				httpheader = headers,
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
			} (cu)

			local c = 0
			local amount = 0
			
			local function logger (data, size)
				-- this function is interesting because catches some outer vars.
				
				print(tostring(c) .. ': received ' .. tostring(size) .. ' bytes more')
				c = c + 1
				amount = amount + size
			end
			
			local code, thread, memory = curl.curl_easy_setopt_writefunction1(cu, logger)
			assert(code == 0)

			code = curl.curl_easy_perform(cu)
			assert(code == 0)

			local response = curl.curl_easy_getopt_writedata(memory)
			curl.libc_free(memory)
			
			thread = nil	-- allows the GC to reclaim the working thread.
			
			assert(#response == amount)	-- cumulated size has to equal the actual size.
			print('\n'..response)
		end)
end


local function apptivegrid_upload (cu, entity_json)

	curl.with_http_header_do({ ['Content-Type'] = 'application/json' },
		function (headers) 
			
			curl.curl_easy_setopt {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee/entities?layout=property',
				verbose = true,
				header = false,
				postfields = entity_json,
				cainfo = 'curl-ca-bundle.crt',
				httpheader = headers,
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
			} (cu)

			code = curl.curl_easy_perform(cu)
			assert(code == 0)

			local response_code = curl.curl_easy_getinfo_response_code(cu)
			assert(response_code == 201)
		end)
end

local entity_json = [[

  {
    "created": "2022-09-14T09:31:00+00:00",
    "replicationkey": 123,
    "locationoutgoing": 456,
    "locationincoming":789,
    "commandurl": [],
    "attachmentcount": 0,
    "status": "new",
    "errortext": null
  }

]]

--------------------------------------------------------------------------------

--curl.with_easy_handle_do(G)
--curl.with_easy_handle_do(apptivegrid_plain)
--curl.with_easy_handle_do(apptivegrid)
--curl.with_easy_handle_do(apptivegrid1)
curl.with_easy_handle_do(function (cu) apptivegrid_upload(cu, entity_json) end)

-- End of the script.
print('\nBye.')

--------------------------------------------------------------------------------

--[[
local S = curl.test(42)
print(type(S))

local a = 42
local S = curl.test_func(function (b) return a + b end)
print(type(S))
--]]
