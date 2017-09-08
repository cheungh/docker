#!/bin/sh
export TERM=xterm
set -u

# Fix data ownership
mkdir -p /opt/elasticsearch/data
chown -R elasticsearch:elasticsearch /opt/elasticsearch/data

mkdir -p /backup
chown -R elasticsearch:elasticsearch /backup

# User params
ELASTICSEARCH_CONFIG="/opt/elasticsearch/config/elasticsearch.yml"
ELASTICSEARCH_USER_PARAMS=$@

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

install_marvel_agent() {
  log "Installing Marvel Agent and Trial License."
  /opt/elasticsearch/bin/plugin install license
  /opt/elasticsearch/bin/plugin install marvel-agent
  chown -R elasticsearch:elasticsearch /opt/elasticsearch/
  log "Marvel Agent Installed"
}

#######################################
# Dump current $ELASTICSEARCH_CONFIG
#######################################
print_config() {
  log "Current Elasticsearch config ${ELASTICSEARCH_CONFIG}:"
  printf '=%.0s' {1..100} && echo
  cat ${ELASTICSEARCH_CONFIG}
  printf '=%.0s' {1..100} && echo
}

# Marvel support check
if [[ ${MARVEL_SUPPORT} == "true" || ${MARVEL_SUPPORT} == "yes" ]]; then
  install_marvel_agent
fi

# Launch Elasticsearch.
print_config
su elasticsearch -c "/opt/elasticsearch/bin/elasticsearch --network.bind_host 0.0.0.0 --network.publish_host _non_loopback:ipv4_ ${ELASTICSEARCH_USER_PARAMS}"
