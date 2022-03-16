#!/bin/bash

script_full_path=$(realpath $0)
home_path=$(dirname $script_full_path)
pushd $home_path

. ./env_pip2pi.sh
. ../log.sh
. ../common.sh
source /etc/profile

## check python3 is installed
python3_is_installed=$(get_python3_is_installed)
if [ "$FALSE" == "$python3_is_installed" ]; then
    log_warn "python3 is not installed! Please installed python3 first"
    exit
fi

## install pip2pi
pip3 install --upgrade pip
pip3 install pip2pi

## make index
mkdir -p $repo_home

### install some tool basic package
for pkg in ${basic_packages[@]}
do
    pip3 install $pkg
done

### download package
# pip3 download -r $basic_requirement_file -d $repo_home
pip2tgz $repo_home --no-binary=:all: -r $basic_requirement_file

### make index(simple folder)
dir2pi $repo_home

## install httpd and set home path
yum -y install httpd

ln -s /usr/lib/systemd/system/httpd.service /etc/systemd/system/multi-user.target.wants/httpd.service || true

httpd_conf_file=/etc/httpd/conf/httpd.conf
repo_to_replace_str=$(echo "$repo_home" | sed 's/\//\\\//g')
sed -i "s/^DocumentRoot.*/DocumentRoot \"$repo_to_replace_str\"/g" $httpd_conf_file
cat >> $httpd_conf_file << EOF

<Directory $repo_home>
    AllowOverride none
    Require all denied
</Directory>
EOF

popd