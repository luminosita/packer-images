ip=`ip a show dev eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*'`

port=8200
cport=8201

user=vault
group=vault

product=vault

vault_config=/etc/vault.d
vault_tls_config_file="$vault_config/vault_tls.hcl"
vault_non_tls_config_file="$vault_config/vault_non_tls.hcl"
vault_data_folder="/var/lib/vault"

peers=""
declare -A peers_addrs

function create_tls_peers {
	for peer in ${peer_addrs[@]};
	do
        if [ peer != ip ]; then
            peers+=$(cat <<EOF
    retry_join {
        leader_api_addr             = "https://$peer:$port"
        leader_ca_cert_file         = "$vault_config/certs/vault.cert.pem"
        leader_client_cert_file     = "$vault_config/certs/vault-node.crt"
        leader_client_key_file      = "$vault_config/certs/vault-node.key"
    }
EOF
            )

            peers+=$'\n'
        fi
	done
}

function create_non_tls_peers {
	for peer in ${peer_addrs[@]};
	do
        if [ peer != ip ]; then
            peers+=$(cat <<EOF
    retry_join {
        leader_api_addr             = "http://$peer:$port"
    }
EOF
            )

            peers+=$'\n'
        fi
	done
}

function create_tls_config {
    printf "\n%s" \
        "Creating main config ($vault_config_file)" \
        ""
    sleep 2 # Added for human readability

    create_tls_peers "$@"

    tee $vault_tls_config_file  <<EOF
ui                      = true
log_level               = "trace"
api_addr                = "https://$ip:$port"
cluster_addr  			= "https://$ip:$cport"
disable_mlock           = true
disable_cache           = true
cluster_name            = "$cluster_name"

listener "tcp" {
   address              = "0.0.0.0:$port"
   tls_disable          = false
   tls_cert_file        = "$vault_config/certs/vault-node.crt"
   tls_key_file         = "$vault_config/certs/vault-node.key"
   tls_client_ca_file   = "$vault_config/certs/vault.cert.pem"
#   tls_cipher_suites    = "TLS_TEST_128_GCM_SHA256,TLS_TEST_128_GCM_SHA256,TLS_TEST20_POLY1305,TLS_TEST_256_GCM_SHA384,TLS_TEST20_POLY1305,TLS_TEST_256_GCM_SHA384"
}

storage "raft" {
    path        = "$vault_data_folder"
    node_id     = "$node_id"

$peers
}
EOF
}

function create_non_tls_config {
    printf "\n%s" \
        "Creating main config ($vault_config_file)" \
        ""
    sleep 2 # Added for human readability

    create_non_tls_peers "$@"

    tee $vault_non_tls_config_file  <<EOF
ui                      = true
log_level               = "info"
api_addr                = "http://$ip:$port"
cluster_addr  			= "http://$ip:$cport"
disable_mlock           = true
disable_cache           = true
cluster_name            = "$cluster_name"

listener "tcp" {
   address              = "0.0.0.0:8200"
   tls_disable          = true
}

storage "raft" {
    path        = "$vault_data_folder"
    node_id     = "$node_id"

$peers
}
EOF
}

function usage {
	# Display Help
	echo "Create Vault configuration files"
	echo
	echo "Syntax: $script_name create|tls [-n|p|c]"
	echo "Create options:"
	echo "  -n     Node name."
    echo "  -p     Peer URLs."
    echo "  -c     Cluster Name."
	echo "Tls options: "
	echo "  -n     Node name."
    echo "  -p     Peer URLs."
    echo "  -c     Cluster Name."
	echo " "
}

if [ -z "$1" ]; then usage; fi

command=$1

shift 1

while getopts ":n:p:c:" o; do
    case "${o}" in
        n)
            echo "Node ID: ${OPTARG}"
            node_id=${OPTARG}
            ;;
        p)
            echo "Peer URLs: ${OPTARG}"
	        peer_addrs+=(${OPTARG})
            ;;
        c)
            echo "Cluster Name: ${OPTARG}"
	        cluster_name=(${OPTARG})
            ;;
        *)
            usage

            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

