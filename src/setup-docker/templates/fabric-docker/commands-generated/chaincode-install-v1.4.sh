<%/*
  Chaincode install for V1 capabilities.

  Required template parameters:
   - chaincode
   - rootOrg
   - networkSettings
*/-%>
chaincodeBuild <% -%>
  "<%= chaincode.name %>" <% -%>
  "<%= chaincode.lang %>" <% -%>
  "$CHAINCODES_BASE_DIR/<%= chaincode.directory %>"
<% chaincode.channel.orgs.forEach(function (org) { -%>
  <% org.peers.forEach(function (peer) { -%>
    printHeadline "Installing '<%= chaincode.name %>' on <%= chaincode.channel.name %>/<%= org.name %>/<%= peer.name %>" "U1F60E"
    chaincodeInstall <% -%>
      "<%= org.cli.address %>" <% -%>
      "<%= peer.fullAddress %>" <% -%>
      "<%= chaincode.channel.name %>" <% -%>
      "<%= chaincode.name %>" <% -%>
      "<%= chaincode.version %>" <% -%>
      "<%= chaincode.lang %>" <% -%>
      "<%= rootOrg.ordererHead.fullAddress %>" <% -%>
      "<%= !networkSettings.tls ? '' : `crypto-orderer/tlsca.${rootOrg.domain}-cert.pem` %>"
  <% }) -%>
<% }) -%>
printItalics "Instantiating chaincode '<%= chaincode.name %>' on channel '<%= chaincode.channel.name %>' as '<%= chaincode.instantiatingOrg.name %>'" "U1F618"
chaincodeInstantiate <% -%>
  "<%= chaincode.instantiatingOrg.cli.address %>" <% -%>
  "<%= chaincode.instantiatingOrg.headPeer.fullAddress %>" <% -%>
  "<%= chaincode.channel.name %>" <% -%>
  "<%= chaincode.name %>" <% -%>
  "<%= chaincode.version %>" <% -%>
  "<%= chaincode.lang %>" <% -%>
  "<%= rootOrg.ordererHead.fullAddress %>" <% -%>
  '<%- chaincode.init %>' <% -%>
  "<%- chaincode.endorsement %>" <% -%>
  "<%= !networkSettings.tls ? '' : `crypto-orderer/tlsca.${rootOrg.domain}-cert.pem` %>" <% -%>
  "<%= chaincode.privateDataConfigFile || '' %>"
