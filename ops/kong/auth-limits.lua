-- Kong post-function (access phase) for the Auth routes. See docs/AUTHENTICATION.md.
--
-- Tells Auth which network a request comes from, in X-Client-Network, for its own limits,
-- and caps the emails a network can ask for. A network is an IPv4 address or an IPv6 /64:
-- a line is given a whole /64, and privacy addresses rotate inside it.

-- The paths that send an email.
local MAIL = {
  ["/auth/v1/otp"] = true,
  ["/auth/v1/magiclink"] = true,
  ["/auth/v1/recover"] = true,
  ["/auth/v1/resend"] = true,
  ["/auth/v1/signup"] = true,
}

-- Clock windows, in seconds, and the emails a network can ask for in each.
local WINDOWS = { { 300, 5 }, { 3600, 15 }, { 86400, 30 } }

local function network(ip)
  if not ip then return nil end
  if ip:match("^%d+%.%d+%.%d+%.%d+$") then return ip end
  if not ip:find(":", 1, true) then return nil end
  local mapped = ip:lower():match("^::ffff:(%d+%.%d+%.%d+%.%d+)$")
  if mapped then return mapped end
  local head, tail = ip:match("^(.-)::(.*)$")
  local groups = {}
  for group in (head or ip):gmatch("[^:]+") do groups[#groups + 1] = group end
  if head then
    -- "::" stands for the groups left out of the eight.
    local trailing = {}
    for group in tail:gmatch("[^:]+") do trailing[#trailing + 1] = group end
    for _ = 1, 8 - #groups - #trailing do groups[#groups + 1] = "0" end
    for _, group in ipairs(trailing) do groups[#groups + 1] = group end
  end
  local prefix = {}
  for i = 1, 4 do
    local value = tonumber(groups[i] or "0", 16)
    if not value then return nil end
    prefix[i] = string.format("%x", value)
  end
  return table.concat(prefix, ":") .. "::/64"
end

local function key(window, now, client)
  return "auth-mail:" .. window[1] .. ":" .. math.floor(now / window[1]) .. ":" .. client
end

return function()
  -- Cloudflare sets the visitor's address, and is the only way in. Calls from inside the
  -- stack have none, and Auth leaves them unlimited.
  local client = network(kong.request.get_header("cf-connecting-ip"))
  if not client then
    kong.service.request.clear_header("x-client-network")
    return
  end
  kong.service.request.set_header("x-client-network", client)

  local path = kong.request.get_path():lower():gsub("/+", "/"):gsub("(.)/$", "%1")
  if kong.request.get_method() ~= "POST" or not MAIL[path] then return end
  local counters = ngx.shared.kong_rate_limiting_counters
  local now = ngx.time()
  for _, window in ipairs(WINDOWS) do
    if (counters:get(key(window, now, client)) or 0) >= window[2] then
      -- Auth's own answer to too many requests, which both apps already explain.
      return kong.response.exit(429,
        { code = 429, error_code = "over_request_rate_limit", msg = "Request rate limit reached" },
        { ["Retry-After"] = tostring(window[1] - now % window[1]) })
    end
  end
  for _, window in ipairs(WINDOWS) do
    counters:incr(key(window, now, client), 1, 0, window[1])
  end
end
