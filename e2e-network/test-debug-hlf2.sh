#!/bin/sh

TEST_TMP="$(rm -rf "$0.tmpdir" && mkdir -p "$0.tmpdir" && (cd "$0.tmpdir" && pwd))"
TEST_LOGS="$(mkdir -p "$0.logs" && (cd "$0.logs" && pwd))"
FABRICA_HOME="$TEST_TMP/../.."

# testing absolute path FIXME
CONFIG="$FABRICA_HOME/samples/fabricaConfig-debug-hlf2.json"

networkUpAsync() {
  "$FABRICA_HOME/fabrica-build.sh" &&
    (cd "$TEST_TMP" && "$FABRICA_HOME/fabrica.sh" generate "$CONFIG") &&
    (cd "$TEST_TMP" && "$FABRICA_HOME/fabrica.sh" up &)
}

dumpLogs() {
  echo "Saving logs of $1 to $TEST_LOGS/$1.log"
  mkdir -p "$TEST_LOGS" &&
    docker logs "$1" >"$TEST_LOGS/$1.log" 2>&1
}

networkDown() {
  rm -rf "$TEST_LOGS" &&
    dumpLogs "ca.root.com" &&
    dumpLogs "orderer0.root.com" &&
    dumpLogs "ca.org1.com" &&
    dumpLogs "peer0.org1.com" &&
    dumpLogs "peer1.org1.com" &&
    dumpLogs "cli.org1.com" &&
    (cd "$TEST_TMP" && "$FABRICA_HOME/fabrica.sh" down)
}

waitForContainer() {
  sh "$TEST_TMP/../wait-for-container.sh" "$1" "$2"
}

waitForChaincode() {
  sh "$TEST_TMP/../wait-for-chaincode.sh" "$1" "$2" "$3" "$4" "$5"
}

expectInvoke() {
  sh "$TEST_TMP/../expect-invoke-tls.sh" "$1" "$2" "$3" "$4" "$5" "$6"
}

networkUpAsync

# shellcheck disable=2015
waitForContainer "ca.root.com" "Listening on http://0.0.0.0:7054" &&
  waitForContainer "ca.org1.com" "Listening on http://0.0.0.0:7054" &&
  waitForContainer "peer0.org1.com" "Elected as a leader, starting delivery service for channel my-channel1" &&
  waitForContainer "peer1.org1.com" "Elected as a leader, starting delivery service for channel my-channel2" &&
  networkDown || (networkDown && exit 1)
