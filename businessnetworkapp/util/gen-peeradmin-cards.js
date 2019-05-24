/**
 * This utility generates the peer admin card for the organization.
 * 1. Picks up the certificates from under the fabric-ca/client folders
 * 2. Creates the connection profile by leveraging the env/components
 * 
 * Usage:  node gen-peeradmin-card.js   profile    org    peer
 *  Profile=Name of the YAML file under env folder
 *  Org=Organization
 *  Peer=For which the card needs to be generated
 * 
 * Bad YAML will throw a parse exception
 *         //             "endorsingPeer": true,
        // "chaincodeQuery": true,
        // "ledgerQuery": true,
        // "eventSource": true
 */
YAML = require('yamljs');
fs = require('fs');
var common = require('composer-common')

const   CARD_FOLDER="../cards/"
const   FABRIC_CA_CLIENT="../../fabric-ca/client/"
const   PROFILE_FOLDER="../../env/"

genCards()

function  genCards(){
    if(process.argv.length < 3){
        console.log("Missing profile file name!!!")
        usage();
    }

    // console.log(process.argv)

    // return

    // var yamlString = fs.readFileSync("../../env/single-org.yaml", 'utf8')

    var yamlString = fs.readFileSync(PROFILE_FOLDER+process.argv[2], 'utf8')
    // Parse the YAML
    var yamlObj = YAML.parse(yamlString)

    setNulltoObject(yamlObj)
    // process.exit(0)

    /**
     * Loop through the orgs
     * Loop through the peers in each org
     */
    for(org in yamlObj.organizations){
        // console.log(org)
        for(var i=0; i < yamlObj.organizations[org].peers.length;i++){
            for(peer in yamlObj.organizations[org].peers[i]){
                console.log("Generating card for:",org, peer)
                var metadata=genMetaData(org, peer);
                var connectionProfile=genConnProfile(yamlObj, org, peer);

                //  connectionProfile = JSON.parse(fs.readFileSync('./conn_template.json', 'utf8'));
                //console.log(JSON.stringify(connectionProfile,null,2))

                var credentials = { certificate:getAdminCert(org) , privateKey: getAdminPrivateKey(org) }
                
                var card = new common.IdCard(metadata, connectionProfile);
                card.setCredentials(credentials);

                writeCardFile(card, metadata)
        }
    }
}
// var cp = genConnProfile(yamlObj,'acme','acme-peer1')
// console.log(JSON.stringify(cp,null,2))
// Generates the connection profile
function genConnProfile(yaml,org,peer){
    var cp=JSON.parse(fs.readFileSync('./conn_template.json', 'utf8'));

    //1. Set the CA server
    cp.certificateAuthorities={
        [yaml.ca.name]: {
            "caName": yaml.ca.name,
            "url": yaml.ca.url
        }
    }

    //2. Set the peers
    // console.log("---",yaml.organizations[org].peers[0], peer )
    cp.peers={
        [peer]:genPeerUrls(yaml.organizations[org].peers, peer)
    }

    

    //3. Set the orderers
    cp.orderers=yamlObj.orderers

    //4. Set the organizations
    var orgCapitalized=capitalize(org)
    cp.organizations={
        [orgCapitalized]:{
            "mspid": genMSPId(org),
            "peers": [
                peer
            ],
            "certificateAuthorities": [
                yaml.ca.name
            ]
        }
    }

    //5. Channels
    //If peer is part of the channel only then include it
    cp.channels={}
    for(channel in yaml.channels){
        // console.log(yaml.channels[channel].peers)
        for(channelPeer in yaml.channels[channel].peers){
            
            if(channelPeer === peer){
                //console.log(channel,'-------',channelPeer,"-------------", peer)
                cp.channels[channel]=yaml.channels[channel]
                // cp.channels[channel].peers[peer]={ }
            }
        }
    }

    //6. client
    cp.client.organization=capitalize(org);

    return cp;
}

function genMetaData(org,peer){
    var name=capitalize(peer)+"PeerAdmin";
    var metadata={"version":1,"userName":"AcmePeerAdmin","roles":["PeerAdmin","ChannelAdmin"]}
    metadata.userName=name
    return metadata
}


// Simply capitalizes the first letter
function capitalize(s) {
    return s[0].toUpperCase() + s.slice(1);
}

function genMSPId(org){
    var capitalized = capitalize(org)
    return capitalized+"MSP"
}

function getAdminCert(org){
    var CERT_FILE=FABRIC_CA_CLIENT+org+"/admin/msp/signcerts/cert.pem"
    return fs.readFileSync(CERT_FILE,'utf8')
}

function getAdminPrivateKey(org){
    var PRIVATE_KEY_FILE=FABRIC_CA_CLIENT+org+"/admin/msp/keystore"
    var files = fs.readdirSync(PRIVATE_KEY_FILE);
    PRIVATE_KEY_FILE=PRIVATE_KEY_FILE+"/"+files[0];
    return fs.readFileSync(PRIVATE_KEY_FILE,'utf8')
}

// Extracts the urls from peers array
function genPeerUrls(peersArray, peer){
    for(var i=0;  i < peersArray.length ;i++){
        for(peerInArray in peersArray[i]){
            if(peerInArray === peer){
                return peersArray[i][peer]
            }
        }
    }
}

// Writes out the card file
function writeCardFile(card, metadata){
    var fileName=metadata.userName+".card"
    card.toArchive({type: "nodebuffer"}).then((buf)=>{
        // console.log(metadata)
        fs.writeFileSync(CARD_FOLDER+fileName,buf)
    });
}
}

function setNulltoObject(yaml){
    for(channel in yaml.channels){
        // console.log(yaml.channels[channel].peers)
        for(channelPeer in yaml.channels[channel].peers){
            
            //console.log(yaml.channels[channel].peers[channelPeer])
            if(yaml.channels[channel].peers[channelPeer] == null)
                yaml.channels[channel].peers[channelPeer]={}
        }
    }
}

// Prints usage to the console
function usage(){
    console.log('Usage:  node gen-peeradmin-card.js setup-profile')
    console.log('        setup-profile = YAML file under the env folder')
    process.exit(0)
}