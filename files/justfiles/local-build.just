# Standalone registry module for BlueBuild (e.g. justfiles/registry.just)

registry := "localhost:5000"

# One-time setup: allow unencrypted transport on loopback
setup-registry:
    sudo mkdir -p /etc/containers/registries.conf.d
    printf '[[registry]]\nlocation = "localhost:5000"\ninsecure = true\n\n[[registry]]\nlocation = "127.0.0.1:5000"\ninsecure = true\n' | sudo tee /etc/containers/registries.conf.d/local-registry.conf > /dev/null
    @echo "Configuration written to /etc/containers/registries.conf.d/local-registry.conf"

# Start registry bound strictly to loopback
start-registry:
    @podman start local-registry 2>/dev/null || podman run -d \
        --name local-registry \
        -p 127.0.0.1:5000:5000 \
        -v registry-data:/var/lib/registry:Z \
        docker.io/library/registry:2
    @echo "Registry active on {{registry}}."

# Start the Web UI at http://localhost:5001
start-git-ui: start-registry
    @podman start registry-ui 2>/dev/null || podman run -d \
        --name registry-ui \
        -p 127.0.0.1:5001:80 \
        -e REGISTRY_URL=http://127.0.0.1:5000 \
        -e DELETE_IMAGES=true \
        docker.io/joxit/docker-registry-ui:static
    @echo "Registry UI active at http://localhost:5001"

# Stop registry and UI containers
stop-registry:
    @podman stop -t 1 registry-ui local-registry 2>/dev/null || true
    @echo "Containers stopped."

# Compile image locally via BlueBuild
build recipe="recipe.yml":
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{recipe}}"
    found=""
    for cand in "$target" "${target}.yml" "${target}.yaml" "recipes/$target" "recipes/${target}.yml" "recipes/${target}.yaml" "$HOME/Projects"/*/recipes/"$target" "$HOME/Projects"/*/recipes/"${target}.yml" "$HOME/Projects"/*/recipes/"${target}.yaml" "$HOME/Projects"/*/"$target"; do
        if [ -f "$cand" ]; then
            found="$cand"
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "Error: recipe file for '{{recipe}}' not found." >&2
        exit 1
    fi

    dir=$(dirname "$found")
    if [ "$(basename "$dir")" = "recipes" ]; then
        cd "$dir/.."
        rel_recipe="recipes/$(basename "$found")"
    else
        cd "$dir"
        rel_recipe="$(basename "$found")"
    fi

    image_name=$(grep -E '^[[:space:]]*name:' "$rel_recipe" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_name" ] && image_name="bluewhale"

    echo "==> Building ${image_name} (${rel_recipe}) via BlueBuild..."
    bluebuild build "$rel_recipe"

# Tag and push: :latest, :<image_version>, and :<git_sha>
push-build recipe="recipe.yml": start-registry
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{recipe}}"
    found=""
    for cand in "$target" "${target}.yml" "${target}.yaml" "recipes/$target" "recipes/${target}.yml" "recipes/${target}.yaml" "$HOME/Projects"/*/recipes/"$target" "$HOME/Projects"/*/recipes/"${target}.yml" "$HOME/Projects"/*/recipes/"${target}.yaml" "$HOME/Projects"/*/"$target"; do
        if [ -f "$cand" ]; then
            found="$cand"
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "Error: recipe file for '{{recipe}}' not found." >&2
        exit 1
    fi

    dir=$(dirname "$found")
    if [ "$(basename "$dir")" = "recipes" ]; then
        cd "$dir/.."
        rel_recipe="recipes/$(basename "$found")"
    else
        cd "$dir"
        rel_recipe="$(basename "$found")"
    fi

    image_name=$(grep -E '^[[:space:]]*name:' "$rel_recipe" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_name" ] && image_name="bluewhale"

    image_version=$(grep -E '^[[:space:]]*image-version:' "$rel_recipe" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_version" ] && image_version="latest"

    git_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")

    echo "==> Pushing tags for ${image_name} (v${image_version}, commit ${git_sha})..."
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:latest"
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:${image_version}"
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:${git_sha}"

    podman push --tls-verify=false "{{registry}}/${image_name}:latest"
    podman push --tls-verify=false "{{registry}}/${image_name}:${image_version}"
    podman push --tls-verify=false "{{registry}}/${image_name}:${git_sha}"

# One-time switch: builds, pushes all tags, rebases host, and cleans up
rebase recipe="recipe.yml": start-registry (push-build recipe)
    #!/usr/bin/env bash
    set -euo pipefail
    target="{{recipe}}"
    found=""
    for cand in "$target" "${target}.yml" "${target}.yaml" "recipes/$target" "recipes/${target}.yml" "recipes/${target}.yaml" "$HOME/Projects"/*/recipes/"$target" "$HOME/Projects"/*/recipes/"${target}.yml" "$HOME/Projects"/*/recipes/"${target}.yaml" "$HOME/Projects"/*/"$target"; do
        if [ -f "$cand" ]; then
            found="$cand"
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "Error: recipe file for '{{recipe}}' not found." >&2
        exit 1
    fi

    image_name=$(grep -E '^[[:space:]]*name:' "$found" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_name" ] && image_name="bluewhale"

    echo "==> Rebasing host to ${image_name}:latest..."
    sudo bootc switch "{{registry}}/${image_name}:latest" || \
    sudo rpm-ostree rebase "ostree-unverified-registry:{{registry}}/${image_name}:latest"
    podman stop -t 1 local-registry 2>/dev/null || true

# Routine update: starts registry, builds, tags all three, upgrades host, and stops container
update-build recipe="recipe.yml":
    #!/usr/bin/env bash
    set -euo pipefail
    trap "podman stop -t 1 local-registry 2>/dev/null || true" EXIT

    target="{{recipe}}"
    found=""
    for cand in "$target" "${target}.yml" "${target}.yaml" "recipes/$target" "recipes/${target}.yml" "recipes/${target}.yaml" "$HOME/Projects"/*/recipes/"$target" "$HOME/Projects"/*/recipes/"${target}.yml" "$HOME/Projects"/*/recipes/"${target}.yaml" "$HOME/Projects"/*/"$target"; do
        if [ -f "$cand" ]; then
            found="$cand"
            break
        fi
    done
    if [ -z "$found" ]; then
        echo "Error: recipe file for '{{recipe}}' not found." >&2
        exit 1
    fi

    dir=$(dirname "$found")
    if [ "$(basename "$dir")" = "recipes" ]; then
        cd "$dir/.."
        rel_recipe="recipes/$(basename "$found")"
    else
        cd "$dir"
        rel_recipe="$(basename "$found")"
    fi

    image_name=$(grep -E '^[[:space:]]*name:' "$rel_recipe" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_name" ] && image_name="bluewhale"

    image_version=$(grep -E '^[[:space:]]*image-version:' "$rel_recipe" | head -n 1 | sed -e 's/#.*//' -e 's/.*:[[:space:]]*//' -e 's/[" '\'' ]//g')
    [ -z "$image_version" ] && image_version="latest"

    git_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")

    echo "==> Starting registry..."
    podman start local-registry 2>/dev/null || podman run -d \
        --name local-registry \
        -p 127.0.0.1:5000:5000 \
        -v registry-data:/var/lib/registry:Z \
        docker.io/library/registry:2

    echo "==> Building ${image_name} (${rel_recipe})..."
    bluebuild build "${rel_recipe}"

    echo "==> Tagging and pushing: latest, ${image_version}, and ${git_sha}..."
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:latest"
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:${image_version}"
    podman tag "${image_name}:latest" "{{registry}}/${image_name}:${git_sha}"

    podman push --tls-verify=false "{{registry}}/${image_name}:latest"
    podman push --tls-verify=false "{{registry}}/${image_name}:${image_version}"
    podman push --tls-verify=false "{{registry}}/${image_name}:${git_sha}"

    echo "==> Staging OS update..."
    sudo bootc upgrade || sudo rpm-ostree upgrade
