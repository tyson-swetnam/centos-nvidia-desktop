FROM centos:7

# Copy Xorg file for 4x 4k monitors
COPY xorg.conf /etc/X11/xorg.conf

# Now install the Xorg stack with the KDE desktop manager:
RUN yum install epel-release \
    && yum update \
    && yum groupinstall "Development Tools" \
    && yum install xorg-* kernel-devel dkms python-pip lsb \
    && pip install awscli \
    && yum groupinstall "KDE Plasma Workspaces" 
    
# Install NVIDIA drivers - note we're pulling these from AWS
RUN aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/ . \
    && chmod +x latest/NVIDIA-Linux-x86_64-390.57-grid.run \
    && .latest/NVIDIA-Linux-x86_64-390.57-grid.run \
    # register the driver with dkms, ignore errors associated with 32bit compatible libraries
    && systemctl set-default graphical.target
    
# Install DCV
RUN yum localinstall nice-* \
    && systemctl enable dcvserver \
    && systemctl start dcvserver

ENTRYPOINT "dcv create-session --type=console --owner centos session1 && dcv list-sessions"
