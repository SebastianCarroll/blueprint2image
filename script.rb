require 'json'
require 'pp'
require 'pry'

blueprint = File.read('cluster_blueprint.json')
bl_json = JSON.parse(blueprint)

# Mapping host group names to components installed.
host2comps = bl_json['host_groups']

host_g_file = File.read('hostgroups.json')
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
  comps.map{|e| e["name"]}
end

hostnames_comps = host2comps.reduce(Hash.new) do |acc, hosts|
  (name, comps) = simplify_hosts_2(hosts)
  acc[name] = simplify_comps(comps)
  acc
end

pp hostnames_comps
