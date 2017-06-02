#!/bin/bash
backup_dir="/backup"
temp_dir="/cp2da"
template="/cp2da/template.conf"
da_ip="103.27.238.106"

cfile(){
    str=$1
    file=$2
    echo -e ${str}|sed 's/ //g' > ${file}
}
precheck() {
    if [ ! -d $temp_dir ]
    then
        mkdir $temp_dir
    fi
    if [ ! -f $template ]
    then
        str="dnscontrol=OFF\n
        docsroot=./data/skins/enhanced\n
        domainptr=unlimited\n
        ftp=unlimited\n
        inode=unlimited\n
        language=en\n
        login_keys=OFF\n
        mysql=unlimited\n
        name=tunglam\n
        nemailf=unlimited\n
        nemailml=unlimited\n
        nemailr=unlimited\n
        nemails=unlimited\n
        notify_on_all_question_failures=yes\n
        notify_on_all_twostep_auth_failures=yes\n
        ns1=ns1.google.com\n
        ns2=ns2.google.com\n
        nsubdomains=unlimited\n
        package=custom\n
        php=ON\n
        quota=unlimited\n
        security_questions=no\n
        sentwarning=no\n
        skin=enhanced\n
        spam=ON\n
        ssh=OFF\n
        ssl=ON\n
        suspend_at_limit=OFF\n
        suspended=no\n
        sysinfo=OFF\n
        twostep_auth=no\n
        usertype=user\n
        vdomains=unlimited\n
        zoom=100"
        cfile ${str} ${template}
    fi
}
cfile(){
    str=$1
    file=$2
    echo -e ${str}|sed 's/ //g' > ${file}
}
transfer() {
    file=$1
    tar -xzvf ${file}
    user=$(echo ${file} | sed -r "s/^cpmove-(.+)/\1/g")
    domain=$(sed -n -r "s/^DNS=(.+)$/\1/p" cpmove-chmp/cp/chmp)
    email=$(sed -n -r "s/^CONTACTEMAIL=(.+)$/\1/p" cpmove-chmp/cp/chmp)

    # Create directories.
    mkdir -p -m 0755 ${temp_dir}/${user}/domains/$domain
    mkdir -p -m 0755 ${temp_dir}/${user}/backup/$domain
    mkdir -m 0755 ${temp_dir}/${user}/backup/$domain/email
    mkdir -m 0755 ${temp_dir}/${user}/backup/$domain/email/data
    

    # Create file domain.conf
    domain_conf="UseCanonicalName=OFF\n
    active=yes\n
    bandwidth=unlimited\n
    cgi=ON\n
    defaultdomain=yes\n
    domain=${domain}\n
    ip=${da_ip}\n
    open_basedir=ON\n
    php=ON\n
    private_html_is_link=0\n
    quota=unlimited\n
    safemode=OFF\n
    ssl=ON\n
    suspended=no\n
    username=${user}"
    cfile ${domain_conf}  ${temp_dir}/${user}/backup/$domain/domain.conf
    
    # Add data to user.conf
    echo domain=${domain} >> ${temp_dir}/${user}/user.conf
    echo "ip=${da_ip}" >> "${temp_dir}"/"${user}"/user.conf
    echo "email=${email}" >> "${temp_dir}"/"${user}"/user.conf
    echo "email=${email}" >> "${temp_dir}"/"${user}"/user.conf
    # Create file domain.usage
    dm_usage="quota=0\n
    bandwidth=0\n
    log_quota=0"
    cfile ${dm_usaga} ${temp_dir}/${user}/backup/$domain/domain.usage

    # Create file ftp.conf
    ftp_conf="Anonymous=no\n
    AnonymousUpload=no"
    cfile ${ftp_conf} ${temp_dir}/${user}/backup/$domain/ftp.conf
    # Create file ftp.passwd
    ftp_pass="${user}=passwd=$(cat cpmove-{user}/backup/.shadow)&type=system"
    cfile ${ftp_pass} ${temp_dir}/${user}/backup/$domain/ftp.passwd
}
precheck
transfer cpmove-haha.tar.gz
    
   

