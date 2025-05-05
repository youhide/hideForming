storage "file" {
  path = "{{ vault_data_dir }}"
}

listener "tcp" {
  address = "0.0.0.0:{{ vault_port }}"
  tls_disable = 1  # Disabled for homelab, enable TLS in production environments
}

api_addr = "{{ vault_api_addr }}"
ui = true
disable_mlock = true  # Disable mlock to resolve memory allocation error
