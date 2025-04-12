FROM jenkins/agent:latest
USER root
# Install necessary tools, including git, docker CLI, and dependencies
RUN apt-get update && apt-get install -y \
    curl unzip zip git \
    docker.io \
    sudo \
    apt-transport-https ca-certificates gnupg lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Download and install Gradle
ARG GRADLE_VERSION=8.2
RUN curl -L "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip" -o gradle.zip && \
    unzip gradle.zip && \
    rm gradle.zip && \
    mv "gradle-${GRADLE_VERSION}" /opt/gradle

# Configure sudo for jenkins user - with more robust directory creation
RUN usermod -aG sudo jenkins && \
    mkdir -p /etc/sudoers.d && \
    ls -la /etc && \
    ls -la /etc/sudoers.d || mkdir -p /etc/sudoers.d && \
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins && \
    chmod 0440 /etc/sudoers.d/jenkins && \
    cat /etc/sudoers.d/jenkins

# Ensure the Gradle directory exists and is writable
RUN mkdir -p /home/jenkins/.gradle && chown -R jenkins:jenkins /home/jenkins/.gradle

# Allow jenkins user to run Docker without sudo
RUN usermod -aG docker jenkins

# Download kubectl, make it executable, and place it in /usr/bin
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/bin/kubectl

# Install Google Cloud SDK and GKE auth plugin (with appropriate error checking)
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && \
    apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin && \
    gke-gcloud-auth-plugin --version || echo "Plugin installation verification failed"

# Create docker-entrypoint.sh
RUN cat <<'EOF' > /docker-entrypoint.sh
#!/bin/bash
set -e

if [ ! -f /etc/sudoers.d/jenkins ]; then
    mkdir -p /etc/sudoers.d
    echo "jenkins ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/jenkins
    chmod 0440 /etc/sudoers.d/jenkins
fi
chmod 666 /var/run/docker.sock || true

if [ -f /root/.kube/config ]; then
    # Create a backup of the original config
    cp /root/.kube/config /root/.kube/config.original
    
    # Replace localhost references with host.docker.internal
    sed "s/127.0.0.1/host.docker.internal/g" /root/.kube/config.original > /root/.kube/config.modified
    
    # Update the kubeconfig to use the correct GKE auth plugin path
    sed -i 's|/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/gke-gcloud-auth-plugin|/usr/bin/gke-gcloud-auth-plugin|g' /root/.kube/config.modified
    
    # Export variables for use with kubectl
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True
    export KUBECONFIG=/root/.kube/config.modified
    
    # Verify the plugin exists and is executable
    if [ -x /usr/bin/gke-gcloud-auth-plugin ]; then
        echo "GKE auth plugin found and is executable"
    else
        echo "WARNING: GKE auth plugin not found or not executable"
        find / -name gke-gcloud-auth-plugin 2>/dev/null
    fi
fi

# Add to your entrypoint.sh:

# Check for service account key in the standard location
if [ -f "${GOOGLE_APPLICATION_CREDENTIALS}" ]; then
    echo "Activating service account from ${GOOGLE_APPLICATION_CREDENTIALS}"
    gcloud auth activate-service-account --key-file="${GOOGLE_APPLICATION_CREDENTIALS}"
    
    # Set as active account
    SERVICE_ACCOUNT=$(cat "${GOOGLE_APPLICATION_CREDENTIALS}" | grep client_email | cut -d'"' -f4)
    gcloud config set account ${SERVICE_ACCOUNT}
fi

# This line is critical - it executes the command passed to the container
exec "$@"
EOF

RUN chmod +x /docker-entrypoint.sh

# Set environment variables for Gradle and GKE
ENV PATH="/opt/gradle/bin:${PATH}"
ENV USE_GKE_GCLOUD_AUTH_PLUGIN=True

RUN mkdir -p /usr/local/share/ca-certificates
COPY certs/domain.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Verify Gradle installation
RUN gradle -v

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/jenkins-agent"]
