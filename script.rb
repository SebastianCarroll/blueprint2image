require 'json'
require 'pp'
require 'pry'

blueprint_f=ARGV[0]
hostgroups=ARGV[1]

blueprint = File.read(blueprint_f)
bl_json = JSON.parse(blueprint)

# Mapping host group names to components installed.
host2comps = bl_json['host_groups']

host_g_file = File.read(hostgroups)
hg_json = JSON.parse(host_g_file)

# Mapping of host groups to list of FQDNS in that group
host2fqdn = hg_json['host_groups']

## Clean up hostname to fqdn mapping
def simplify_hosts(element)
  name = element["name"]
  hosts = element["hosts"]
  [name, hosts]
end

def simplify_fqdns(fqdns)
  fqdns.map{|e| e["fqdn"]}
end

hostnames_map = host2fqdn.reduce(Hash.new) do |acc, hostm| 
  (name, hosts) = simplify_hosts(hostm)
  acc[name] = simplify_fqdns(hosts)
  acc
end

pp hostnames_map

# Clean up hostname to component mapping
def simplify_hosts_2(e)
  name = e["name"]
  comps = e["components"]
  [name, comps]
end

def simplify_comps(comps)
  comps.map{|e| e["name"]}.sort
end

hostnames_comps = host2comps.reduce(Hash.new) do |acc, hosts|
  (name, comps) = simplify_hosts_2(hosts)
  acc[name] = simplify_comps(comps)
  acc
end

pp hostnames_comps


# Print out the counts
#hostnames_comps.map{ |k,v| puts "#{k} -> #{v.length}" }
counts_services = hostnames_comps.reduce(Hash.new { |h, k| h[k] = [] }) do |acc, (k,v)| 
  acc[v.length] << k
  acc
end

pp counts_services

