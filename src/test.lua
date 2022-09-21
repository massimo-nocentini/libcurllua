
local curl = require 'curl'

local function G (cu)

	local code

	code = curl.curl_easy_setopt_url(cu, 'https://www.google.com')
	assert(code == curl.CURLcode.CURLE_OK)

	code = curl.curl_easy_setopt_verbose(cu, true)
	assert(code == curl.CURLcode.CURLE_OK)

	code = curl.curl_easy_setopt_cainfo(cu, 'curl-ca-bundle.crt')
	assert(code == curl.CURLcode.CURLE_OK)

	code = curl.curl_easy_perform(cu)
	assert(code == curl.CURLcode.CURLE_OK)

end

local function apptivegrid_plain (cu)

	curl.with_http_header_do({ 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		function (headers) 
			
			curl.curl_easy_setopt(cu, {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
				verbose = true,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
				httpheader = headers,
			})

			code = curl.curl_easy_perform(cu)
			assert(code == curl.CURLcode.CURLE_OK)

		end)

end

local function apptivegrid (cu)

	curl.with_http_header_do({ 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		function (headers) 
			
			curl.curl_easy_setopt(cu, {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
				verbose = true,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
				httpheader = headers,
			})

			local code, memory = curl.curl_easy_setopt_writefunction(cu, nil)
			assert(code == curl.CURLcode.CURLE_OK)

			code = curl.curl_easy_perform(cu)
			assert(code == curl.CURLcode.CURLE_OK)

			local response = curl.curl_easy_getopt_writedata(memory)
			curl.libc_free(memory)
			
			print('\n'..response)
		end)

end

local function apptivegrid1 (cu)

	local headers = curl.curl_slist { 
		Accept = 'application/vnd.apptivegrid.hal;version=2' 
	}
			
	local c, amount = 0, 0
	local function logger (data, size)
		-- this function is interesting because catches some outer vars.
		
		print(tostring(c) .. ': received ' .. tostring(size) .. ' bytes more')
		c = c + 1
		amount = amount + size
	end

	local returns = curl.curl_easy_setopt(cu, {
		url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
		verbose = true,
		header = false,
		cainfo = 'curl-ca-bundle.crt',
		httpheader = headers,
		netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
		writefunction = logger,
	})

	local code, memory, thread = returns.writefunction()
	assert(code == curl.CURLcode.CURLE_OK)

	code = curl.curl_easy_perform(cu) -- go!
	assert(code == curl.CURLcode.CURLE_OK)

	local response, size = curl.curl_easy_getopt_writedata(memory)
	
	curl.libc_free(memory)
	curl.curl_slist_free_all(headers)
	
	thread = nil	-- allows the GC to reclaim the working thread.
	
	assert(#response == amount and amount == size)	-- cumulated size has to equal the actual size.
	print('\n'..response)

end


local function apptivegrid2 (cu)

			
	local c, amount = 0, 0
	local function logger (data, size)
		-- this function is interesting because catches some outer vars.
		
		print(tostring(c) .. ': received ' .. tostring(size) .. ' bytes more')
		c = c + 1
		amount = amount + size
	end

	local returns = curl.curl_easy_httpheader_setopt_getinfo {
		httpheader	= { 
			Accept = 'application/vnd.apptivegrid.hal;version=2' 
		},
		setopt		= {	
			url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee',
			verbose = true,
			header = false,
			cainfo = 'curl-ca-bundle.crt',
			netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
			writefunction = logger,
		}
	} (cu)

	local code, response, size = returns.writefunction()
	assert(code == curl.CURLcode.CURLE_OK)
	assert(#response == amount and amount == size)	-- cumulated size has to equal the actual size.
	print('\n'..response)

end


local function apptivegrid_upload (cu, entity_json)

	curl.with_http_header_do({ ['Content-Type'] = 'application/json' },
		function (headers) 
			
			local returns = curl.curl_easy_setopt(cu, {
				url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee/entities?layout=property',
				verbose = true,
				header = false,
				httpheader = headers,
				postfields = entity_json,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
			})

			local code = curl.curl_easy_perform(cu)
			assert(code == curl.CURLcode.CURLE_OK)

			local code, response_code = curl.curl_easy_getinfo_response_code(cu)
			assert(response_code == 201)
		end)
end

local function apptivegrid_upload_1 (cu, entity_json)
		
	local returns, getinfos = curl.curl_easy_httpheader_setopt_getinfo {
		httpheader	= { 
			['Content-Type'] = 'application/json',
		},
		setopt		= {	
			url = 'https://app.apptivegrid.de/api/users/6315f0a9f5ca3bb794a42cb3/spaces/6315f0b667d3ac2664a44f52/grids/631ee7590cb7e1473fa4c5ee/entities?layout=property',
			verbose = true,
			header = false,
			postfields = entity_json,
			cainfo = 'curl-ca-bundle.crt',
			netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
		},
		getinfo 	= { 
			'response_code' 
		}
	} (cu)
	
	local code, response_code = getinfos.response_code()
	assert(code == curl.CURLcode.CURLE_OK)
	assert(response_code == 201)
end

local function aws_geturl (cu)
	
	--[[
	do a GET request at https://7zzn3khlt1.execute-api.eu-central-1.amazonaws.com/uploads with two post arguments:
	fileName (arbitrary, test.txt) and fileType (application/octet-stream)
	a json should return with a key 'uploadURL', let be `v` its value.
	do a PUT request at `v` and then a GET to get back the file.
	]]--

	local returns, getinfos = curl.curl_easy_httpheader_setopt_getinfo {
		httpheader	= { 
			['Content-Type'] = 'application/json',
		},
		setopt		= {	
			url = 'https://7zzn3khlt1.execute-api.eu-central-1.amazonaws.com/uploads?fileName=test.txt&fileType=application/octet-stream',
			verbose = true,
			header = false,
			cainfo = 'curl-ca-bundle.crt',
			writefunction = true,	-- means that we just want the whole response, not interested in its chunks.
		}
	} (cu)

	-- just a check of the encoded URL.
	--print(curl.curl_easy_escape(cu, 'https://7zzn3khlt1.execute-api.eu-central-1.amazonaws.com/uploads?fileName=test.txt&fileType=application/octet-stream'))

	local code, response, size = returns.writefunction()
	assert(code == curl.CURLcode.CURLE_OK)
	
	local urls = {}
	for k in string.gmatch(response, '"uploadURL":"([%w%p]+)"') do
       		table.insert(urls, k)
     	end
     	local i = string.find(urls[1], '"', 1, true)
     	local url = string.sub(urls[1], 1, i - 1)

	return url

end

local function aws_puturl (url, payload)

	return function (cu)
	
		returns, getinfos = curl.curl_easy_httpheader_setopt_getinfo {
			httpheader	= { 
				['Content-Type'] = 'text/plain',
			},
			setopt		= {	
				url = url,	-- use here the URL received in the previous call.
				verbose = true,
				header = false,
				postfields = payload,
				cainfo = 'curl-ca-bundle.crt',
				netrc = curl.opt_netrc.CURL_NETRC_OPTIONAL,
			},
			getinfo 	= { 
				'response_code' 
			}
		} (cu)
		
		local code, response_code = getinfos.response_code()
		assert(code == curl.CURLcode.CURLE_OK)
		--assert(response_code == 201)
		print(response_code)

	end	
end

local function aws_get (url) 

	return function (cu)
	
		local returns, getinfos = curl.curl_easy_httpheader_setopt_getinfo {
			httpheader	= { 
				['Content-Type'] = 'text/plain',
			},
			setopt		= {	
				url = url,
				verbose = true,
				header = false,
				cainfo = 'curl-ca-bundle.crt',
				writefunction = true,
			}
		} (cu)

		local code, response, size = returns.writefunction()
		assert(code == curl.CURLcode.CURLE_OK)
		
		return response

	end
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
print('cURL version: ' .. curl.curl_version() .. '\n')
--------------------------------------------------------------------------------

--curl.curl_easy_do(G)
--curl.curl_easy_do(apptivegrid_plain)
--curl.curl_easy_do(apptivegrid)
--curl.curl_easy_do(apptivegrid1)
--curl.curl_easy_do(apptivegrid2)
--curl.curl_easy_do(function (cu) apptivegrid_upload(cu, entity_json) end)
--curl.curl_easy_do(function (cu) apptivegrid_upload_1(cu, entity_json) end)

local url = curl.curl_easy_do(aws_geturl)
local url = curl.curl_easy_do(aws_puturl(url, 'Hello, World!'))
--local response = curl.curl_easy_do(aws_get(url))
--print(response)


--------------------------------------------------------------------------------

print('\nBye.')

--[[
local S = curl.test(42)
print(type(S))

local a = 42
local S = curl.test_func(function (b) return a + b end)
print(type(S))
--]]
