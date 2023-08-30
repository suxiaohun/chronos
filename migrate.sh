#!/bin/bash

# set -e

cmd="$1"

# TODO change me
root_path=/engine-entity-service
migrate_tool="${root_path}/migrate.linux"
migrate_source="${root_path}/migrations/cassandra"
migrate_source_ck="${root_path}/migrations/clickhouse"

init_nebula_schema_tool="${root_path}/migrations/init_nebula_schema"
init_nebula_config="${root_path}/config/server.json"
init_nebula_schema="${root_path}/migrations/nebula"
# TODO use last schema version before we migration to new init system
# migrate_init_version=0

init_es_config="${root_path}/migrations/es/entity-vertex.json"

m_mysql_address=${MYSQL_ADDRESS:-mysql-default.component.svc.cluster.local}
m_mysql_username=${MYSQL_USERNAME:-root}
m_mysql_password=${MYSQL_PASSWORD:-root}
m_mysql_database=${MYSQL_DATABASE:-viper_test}


m_clickhouse_username=${CLICKHOUSE_USERNAME:-clickhouse}
m_clickhouse_password=${CLICKHOUSE_PASSWORD:-clickhouse}
m_clickhouse_database=${CLICKHOUSE_DATABASE:-bdp}
check_component_loop_uplimit=120


# just a template
migrate_mysql()
{
    m_mysql_url="mysql://$m_mysql_username:$m_mysql_password@tcp($m_mysql_address)/$m_mysql_database"

    echo "migrating for mysql, address: $m_mysql_address, keyspace: $m_mysql_keyspace"
    "$migrate_tool" -source=$migrate_source -database="$m_mysql_url" up || exit 1
}

init_nebula_schema()
{
  check_nebula_space
  echo "init_nebula_schema path: $init_nebula_schema"
  echo "init_nebula_config path: $init_nebula_config"
  echo -e "\n ....start init nebula schema"
  "$init_nebula_schema_tool" -nblSchema=$init_nebula_schema -config=$init_nebula_config -isUp=true || exit 1
}

check_nebula_space()
{
  for ((i=0; i<$check_component_loop_uplimit; i++));
        do
            /nebula-console -u $NEBULA_USERNAME -p $NEBULA_PASSWORD -addr ${NEBULA_ADDRESS%:*} -port ${NEBULA_ADDRESS#*:} -e "SHOW SPACES;" | grep $NEBULA_SPACE
            if [[ $? -ne 0 ]];then
                    echo "Nebula space is not ready, wait for another try."
                    sleep 3
                    continue
            else
                break
            fi
        done
  if [[ $i -eq $check_component_loop_uplimit ]];then
      echo "Nebula space is not ready, stop init component."
      exit 1
  fi
}

check_ck_database()
{
    IFS=';' read -ra ADDR <<< "$CLICKHOUSE_ADDRESS"
    for i in "${!ADDR[@]}"; do
        m_clickhouse_address=${ADDR[$i]}
        for ((loop_count=0; loop_count<$check_component_loop_uplimit; loop_count++)); do
        echo 'SHOW DATABASES' | curl "${m_clickhouse_address%:*}:8123/?" --data-binary @- | grep $m_clickhouse_database
        if [[ $? -ne 0 ]];then
            echo "Clickhouse database "$m_clickhouse_database" on "$m_clickhouse_address" is not ready, wait for another try."
            sleep 3
            continue
        else
            break
        fi
        done
        if [[ $loop_count -eq $check_component_loop_uplimit ]];then
            echo "Clickhouse database "$m_clickhouse_database" on "$m_clickhouse_address" is not ready, stop init component."
            exit 1
        fi
    done
}

migrate_clickhouse()
{
  check_ck_database
  IFS=';' read -ra ADDR <<< "$CLICKHOUSE_ADDRESS"
  m_clickhouse_url=""
  for i in "${!ADDR[@]}"; do
    echo "Migrating clickhouse ${ADDR[$i]} schema..."
    mkdir $migrate_source_ck/$i
    m_clickhouse_address=${ADDR[$i]}
    INDEX=$i KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1631702147_create_table.up.sql > $migrate_source_ck/$i/1631702147_create_table.up.sql
    INDEX=$i KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1631702147_create_table.down.sql > $migrate_source_ck/$i/1631702147_create_table.down.sql

    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1636515755_create_vehicle_tables.up.sql > $migrate_source_ck/$i/1636515755_create_vehicle_tables.up.sql
    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1636515755_create_vehicle_tables.down.sql > $migrate_source_ck/$i/1636515755_create_vehicle_tables.down.sql

    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1652333349_create_deleted_tracks_table.up.sql > $migrate_source_ck/$i/1652333349_create_deleted_tracks_table.up.sql
    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1652333349_create_deleted_tracks_table.down.sql > $migrate_source_ck/$i/1652333349_create_deleted_tracks_table.down.sql

    INDEX=$i KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1653885195_create_clusters_changelogs.up.sql > $migrate_source_ck/$i/1653885195_create_clusters_changelogs.up.sql
    INDEX=$i KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1653885195_create_clusters_changelogs.down.sql > $migrate_source_ck/$i/1653885195_create_clusters_changelogs.down.sql

    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1655372796_create_ttl_records.up.sql > $migrate_source_ck/$i/1655372796_create_ttl_records.up.sql
    KAFKA_BROKER_LIST="${KAFKA_BROKER_LIST//;/$','}" envsubst < $migrate_source_ck/1655372796_create_ttl_records.down.sql > $migrate_source_ck/$i/1655372796_create_ttl_records.down.sql

    m_clickhouse_url="clickhouse://$m_clickhouse_address?username=$m_clickhouse_username&password=$m_clickhouse_password&database=$m_clickhouse_database&x-multi-statement=true&debug=false"
    echo "migrating for clickhouse, address: $m_clickhouse_address, database: $m_clickhouse_database"
    "$migrate_tool" -source=file://$migrate_source_ck/$i -database="$m_clickhouse_url" up || exit 1
    echo "Migrating clickhouse ${ADDR[$i]} schema... Done"
  done
}

migrate_es()
{
  echo "migrate_es start:"
  echo "init_es_config: $init_es_config"
  cat $init_es_config
  res=$(curl -H "Content-Type: application/json" -X PUT "$ES_ADDRESS/$ES_ENTITY_INDEX_NAME" -T $init_es_config)
  echo "migrate_es done: $res"
}


migrate()
{
#    echo "Migrating filesystem..."
#    echo "Migrating filesystem...Skip"
    echo "Migrating database schema..."

    echo "Migrating ES index..."
    echo "curl -H "Content-Type: application/json" -X PUT "$ES_ADDRESS/$ES_ENTITY_INDEX_NAME" -T $init_es_config"
    migrate_es
    echo "...Migrating ES index done"

    echo "Migrating clickhouse schema..."
    migrate_clickhouse
    echo "...Migrating clickhouse schema done"

    echo "Migrating nebula schema..."
    init_nebula_schema
    echo "...Migrating nebula schema done"

    echo "Migrating database schema...Done"
}

cleanup() {
    echo "Cleaning up database schema..."
    echo "Cleaning up database schema...Done"
    echo "Cleaning up filesystem..."
    echo "Cleaning up filesystem...Skip"
}

# /engine-static-feature-db/migrate-linux-amd64

prompt_yes()
{
echo "Do you wish to run CLEANUP (YES/n)? "
read answer
if [ "$answer" == "YES" ] ;then
    echo "Will run CLEANUP command!"
else
    echo "Aborted..."
    exit
fi
}

echo "Init script for engine-entity-service"
case "$cmd" in
    migrate) echo "Running migrate..."
        migrate
        ;;
    cleanup)
        prompt_yes
        cleanup
        ;;
    *) echo "Unknown command: $cmd"
       echo "Usage: $0 migrate/cleanup"
       exit 1
        ;;
esac


