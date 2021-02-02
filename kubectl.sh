
set -euo pipefail


#HELM_VERSION="v2.11.0"
#
#curl -Lo /tmp/helm-linux-amd64.tar.gz https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
#    && tar -xvf /tmp/helm-linux-amd64.tar.gz -C /tmp/ \
#    && chmod +x /tmp/linux-amd64/helm && mv /tmp/linux-amd64/helm /usr/local/bin/ \
#    && helm init --client-only \
#    && helm version
#

helm version

install_kubectl_if_needed() {
  if hash kubectl 2>/dev/null; then
    echo >&2 "using kubectl from the host system and not reinstalling"
  else
    local bin_dir
    bin_dir="$(go env GOPATH)/bin"
    local -r kubectl_version='v1.14.2'
    local -r kubectl_path="${bin_dir}/kubectl"
    local goos goarch kubectl_url
    goos="$(go env GOOS)"
    goarch="$(go env GOARCH)"
    kubectl_url="https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/${goos}/${goarch}/kubectl"

    echo >&2 "kubectl not detected in environment, downloading ${kubectl_url}"
    mkdir -p "${bin_dir}"
    curl --fail --show-error --silent --location --output "$kubectl_path" "${kubectl_url}"
    chmod +x "$kubectl_path"
    echo >&2 "installed kubectl to ${kubectl_path}"
  fi
}

install_kubectl_if_needed