#!/usr/bin/env bash

if [ ! -d /etc/riak ]; then
  pushd /etc/riak
 expect - <<END_EXPECT
  spawn ./bin/riak console
  expect "(riak@${RIAK_NODE_NAME})1>"
  send "riak_core_bucket_type:create\(<<\"maps\">>, \[\{datatype, map\}, \{allow_mult, true\}\]\), riak_core_bucket_type:activate\(<<\"maps\">>\),riak_core_bucket_type:create\(<<\"sets\">>, \[\{datatype, set\}, \{allow_mult, true\}\]\), riak_core_bucket_type:activate\(<<\"sets\">>),riak_core_bucket_type:create\(<<\"counters\">>, \[\{datatype, counter\}, \{allow_mult, true\}\]\), riak_core_bucket_type:activate\(<<\"counters\">>\).\n"
  expect "ok"
  send "\007"
  send "q\n"
END_EXPECT
  popd
  popd
fi

#pushd riak/rel/riak
#ulimit -n 8192
#ulimit -n
#./bin/riak start
#./bin/riak ping
