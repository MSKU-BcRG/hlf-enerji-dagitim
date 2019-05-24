/**
 * Generates the network admin's card
 * Usage:  node replicate-networkadmin-cards.js  <Env-Profile>
 */
var YAML = require('yamljs');
var inquirer    = require('inquirer');
var fs          = require('fs');
const os        = require('os');
const fsextra = require('fs-extra');

const CARDS_FOLDER="../cards"
const COMPOSER_CARD_FOLDER=os.homedir()+"/.composer/cards"
const COMPOSER_CLIENT_DATA_FOLDER=os.homedir()+"/.composer/client-data"
const   PROFILE_FOLDER="../../env/"

displayCards();

/**
 * Display the cards related to nw admin
 * User will select the card 
 */
function displayCards(){
    var filesComposer = fs.readdirSync(COMPOSER_CARD_FOLDER)
    var question = [
        {
            name: "action",
            message: "Select Network App Card:",
            type: 'list',
            choices: []
        }
    ];
    for(var i=0; i < filesComposer.length;i++){
        if(filesComposer[i].endsWith('@hlfv1')){
            // ignore
        } else {
            question[0].choices.push(filesComposer[i])
        }
    }

    // Let's prompt
    inquirer.prompt(question).then(function(result){
        processSelectedCard(result.action, process.argv[2])
    });
}

/**
 * The selected card is used as a template for generating new cards
 * 1. Gets org from the card
 * 2. Gets the peers for the org from the profile
 * 3. Generates the connection profile for each of the card
 */
function  processSelectedCard(selectedCard, envProfile){
    // Read the connection.json 
    var  metadata=JSON.parse(fs.readFileSync(COMPOSER_CARD_FOLDER+'/'+selectedCard+'/metadata.json', 'utf8'));
    var  connectionProfile = JSON.parse(fs.readFileSync(COMPOSER_CARD_FOLDER+'/'+selectedCard+'/connection.json', 'utf8'));
    var  organization=extractOrganization(connectionProfile)

    // Read the environment profile
    var yamlString = fs.readFileSync(PROFILE_FOLDER+envProfile, 'utf8')
    // Parse the YAML
    var yamlObj = YAML.parse(yamlString)
    var peers = extractPeers(yamlObj, organization)
    //console.log(peers)
    if(peers.length == 0){
        console.log("No peers found for the organization: ", organization,"!!!");
        return;
    }

    // Cards generation
    let  restPeers={}
    for(var i=0; i < peers.length;i++){
        createCard(selectedCard, connectionProfile,peers[i],organization)

        var peerName = extractDynamic(peers[i])

        restPeers[peerName]=peers[i][peerName]

        // console.log(peerName, peers[i])
    }

    // generate the REST server card for the org
    let dummyPeer = {
        'enerjisa-restserver':
                        { url: 'grpc://localhost:8051',
                          eventUrl: 'grpc://localhost:8053' }
    }
    // generate the rest server card
    createCard(selectedCard, connectionProfile,dummyPeer,organization)
    connectionProfile.peers = restPeers;
    // console.log(connectionProfile)
    var cardFolder = COMPOSER_CARD_FOLDER+"/restserver-"+selectedCard
    fs.writeFileSync(cardFolder+"/connection.json", JSON.stringify(connectionProfile));
}

/**
 * Create the card
 * Assumes only peer URL are different everything else stays the same :)
 */
function createCard(templateCardName,connectionProfile,peer,organization){
    connectionProfile.peers=peer
    var peerName = extractDynamic(peer)
    peerName = peerName.replace(organization+"-","")
    var cardFolder = COMPOSER_CARD_FOLDER+"/"+peerName+"-"+templateCardName
    fsextra.mkdirp(cardFolder)
    // write metadata.json
    fs.writeFileSync(cardFolder+"/metadata.json", fs.readFileSync(COMPOSER_CARD_FOLDER+"/"+templateCardName+"/metadata.json"));
    // write connection profile
    fs.writeFileSync(cardFolder+"/connection.json", JSON.stringify(connectionProfile));
    // create the empty credentials folder
    fsextra.mkdirp(cardFolder+"/credentials")
    // create the folder under client-data
    fsextra.copy(COMPOSER_CLIENT_DATA_FOLDER+'/'+templateCardName, COMPOSER_CLIENT_DATA_FOLDER+'/'+peerName+"-"+templateCardName)

    console.log("Created & Deployed card: "+ peerName+"-"+templateCardName);
}


/**
 * Returns the org from the card
 */
function extractOrganization(connectionProfile){
    for(org in connectionProfile.organizations){
        return org.toLowerCase();
    }
}
/**
 * Extracts the peers information from the env profile
 */
function extractPeers(yamlObj, organization){
    for(org in yamlObj.organizations){
        if(org === organization){
            return yamlObj.organizations[org].peers;
        }
    }
    return []
}

/**
 * Extracts the first dynamic property
 */
function extractDynamic(jsonObj){
    for(ele in jsonObj){
        return ele;
    }
}


/**
 * Extracts the orgs from YAML
 */
function getOrgsFromYaml(yamlObj){
    var orgs=[]
    for(ele in yamlObj){
        orgs.push(ele)
    }
    return orgs;
}