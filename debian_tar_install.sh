# install mongodb from a tarball download from 
# https://www.mongodb.com/download-center#community
# automatic install and setting config and serivce.
function build_mongodb()
{
    echo "build_mongo >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    #cd $PKGDIR
    cd /home/xzc/mongodb

    mkdir -p .mongodb
    # --strip-components 1 在解压时自动去除第一层目录
    tar -zxvf mongodb-linux-x86_64-debian71-3.4.4.tgz -C .mongodb --strip-components 1

    # install exec file
    chmod +x .mongodb/bin/*
    cp -R .mongodb/bin/* /usr/bin

    # install mongod service
    wget https://raw.githubusercontent.com/mongodb/mongo/master/debian/init.d -O /etc/init.d/mongod
    755 = -rwxr-xr-x
    chmod 755 /etc/init.d/mongod
    update-rc.d mongod defaults

    LOGDIR=/var/log/mongodb
    DBPATH=/var/lib/mongodb

    # create mongo user and necessary dir
    groupadd --system mongodb
    useradd --no-create-home --system --gid mongodb --shell /sbin/nologin --comment 'mongodb' mongodb
    mkdir -p $LOGDIR
    chown -R mongodb:mongodb $LOGDIR
    mkdir -p $DBPATH
    chown -R mongodb:mongodb $DBPATH

    # setting config
    # manual:https://docs.mongodb.com/manual/reference/configuration-options/
    # example:https://github.com/mongodb/mongo/blob/master/debian/mongod.conf
    # the config path is specify in init.d script
    MONGODCONF=/etc/mongod.conf
    echo "#mongod.conf" > $MONGODCONF
    append_to_file $MONGODCONF 'systemLog:'
    append_to_file $MONGODCONF '   destination: file'
    append_to_file $MONGODCONF '   path: "'$LOGDIR'/mongod.log"'
    append_to_file $MONGODCONF '   logAppend: true'
    append_to_file $MONGODCONF 'storage:'
    append_to_file $MONGODCONF '   dbPath: '$DBPATH
    append_to_file $MONGODCONF '   journal:'
    append_to_file $MONGODCONF '      enabled: true'
    append_to_file $MONGODCONF 'processManagement:'
    append_to_file $MONGODCONF '   fork: true'
    append_to_file $MONGODCONF 'net:'
    append_to_file $MONGODCONF '   bindIp: 127.0.0.1'
    append_to_file $MONGODCONF '   port: 27013'
    append_to_file $MONGODCONF 'setParameter:'
    append_to_file $MONGODCONF '   enableLocalhostAuthBypass: false'
    append_to_file $MONGODCONF 'security:'
    append_to_file $MONGODCONF '   authorization: enabled'

    # start mongo service using /etc/mongod.conf
    service mongod start

    cd -
}