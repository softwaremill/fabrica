<%/*
  Chaincode install and upgrade for V2 capabilities.

  Required bash variables:
   - version
  Required template parameters:
   - chaincode
   - rootOrg
   - networkSettings
*/-%>
printHeadline "Packaging chaincode '<%= chaincode.name %>'" "U1F60E"
chaincodeBuild <% -%>
  "<%= chaincode.name %>" <% -%>
  "<%= chaincode.lang %>" <% -%>
  "$CHAINCODES_BASE_DIR/<%= chaincode.directory %>"
chaincodePackage <% -%>
  "<%= chaincode.instantiatingOrg.cli.address %>" <% -%>
  "<%= chaincode.instantiatingOrg.headPeer.fullAddress %>" <% -%>
  "<%= chaincode.name %>" <% -%>
  "$version" <% -%>
  "<%= chaincode.lang %>" <% -%>
<% chaincode.channel.orgs.forEach(function (org) { -%>
  printHeadline "Installing '<%= chaincode.name %>' for <%= org.name %>" "U1F60E"
  <% org.peers.forEach(function (peer) { -%>
    chaincodeInstall <% -%>
      "<%= org.cli.address %>" <% -%>
      "<%= peer.fullAddress %>" <% -%>
      "<%= chaincode.name %>" <% -%>
      "$version" <% -%>
      "<%= !networkSettings.tls ? '' : `crypto-orderer/tlsca.${rootOrg.domain}-cert.pem` %>"
  <% }) -%>
  chaincodeApprove <% -%>
    "<%= org.cli.address %>" <% -%>
    "<%= org.headPeer.fullAddress %>" <% -%>
    "<%= chaincode.channel.name %>" <% -%>
    "<%= chaincode.name %>" <% -%>
    "$version" <% -%>
    "<%= rootOrg.ordererHead.fullAddress %>" <% -%>
    "<%- chaincode.endorsement || '' %>" <% -%>
    "<%= `${chaincode.initRequired}` %>" <% -%>
    "<%= !networkSettings.tls ? '' : `crypto-orderer/tlsca.${rootOrg.domain}-cert.pem` %>" <% -%>
    "<%= chaincode.privateDataConfigFile || '' %>"
<% }) -%>
printItalics "Committing chaincode '<%= chaincode.name %>' on channel '<%= chaincode.channel.name %>' as '<%= chaincode.instantiatingOrg.name %>'" "U1F618"
chaincodeCommit <% -%>
  "<%= chaincode.instantiatingOrg.cli.address %>" <% -%>
  "<%= chaincode.instantiatingOrg.headPeer.fullAddress %>" <% -%>
  "<%= chaincode.channel.name %>" <% -%>
  "<%= chaincode.name %>" <% -%>
  "$version" <% -%>
  "<%= rootOrg.ordererHead.fullAddress %>" <% -%>
  "<%- chaincode.endorsement || '' %>" <% -%>
  "<%= `${chaincode.initRequired}` %>" <% -%>
  "<%= !networkSettings.tls ? '' : `crypto-orderer/tlsca.${rootOrg.domain}-cert.pem` %>" <% -%>
  "<%= chaincode.channel.orgs.map((o) => o.headPeer.fullAddress).join(',') %>" <% -%>
  "<%= !networkSettings.tls ? '' : chaincode.channel.orgs.map(o => `crypto-peer/${o.headPeer.address}/tls/ca.crt`).join(',') %>" <% -%>
  "<%= chaincode.privateDataConfigFile || '' %>"
