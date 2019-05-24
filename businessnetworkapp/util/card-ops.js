
var fs          = require('fs');
const os        = require('os');
var chalk       = require('chalk');
var figlet      = require('figlet');
var inquirer    = require('inquirer');
var path        = require('path');
const fsextra = require('fs-extra');
const exec = require('child_process').exec;

const CARDS_FOLDER="../cards"
const COMPOSER_CARD_FOLDER=os.homedir()+"/.composer/cards"

// Create the composer/cards folder if it does not exist
if (!fs.existsSync(COMPOSER_CARD_FOLDER)){
    fsextra.mkdirp(COMPOSER_CARD_FOLDER);
}

console.log(
    chalk.yellow(figlet.textSync('ACloudFan.com', { 'horizontalLayout': 'full' })));

inquireAction()

function    inquireAction(){
    var  INSTALL_PEER_ADMIN_CARDS = 'Install/Replace Peer Cards ';
    var  GEN_PEER_ADMIN_CARDS_SINGLE_ORG = 'Generate Peer Admin Cards for Single Org Profile ';
    var  GEN_PEER_ADMIN_CARDS_MULTI_ORG = 'Generate Peer Admin Cards for Multi Org Profile ';
    var  GEN_PEER_ADMIN_CARDS_CLOUD_MULTI_ORG = 'Generate Peer Admin Cards for CLOUD Multi Org Profile ';

    var  GEN_NW_ADMIN_CARDS_SINGLE_ORG = 'Generate Network Admin Cards for Single Org Profile ';
    var  GEN_NW_ADMIN_CARDS_MULTI_ORG = 'Generate Network Admin Cards for Multi Org Profile ';
    var  GEN_NW_ADMIN_CARDS_CLOUD_MULTI_ORG = 'Generate Network Admin Cards for CLOUD Multi Org Profile ';

    var  LIST_CARDS = 'List cards on disk';
    var  DELETE_ALL_CARDS = 'Delete all cards';
        
    var  HELP_CLEANUP = 'Help Cleanup';

    var EXIT = "EXIT";


    var question = [
        {
            name: "action",
            message: "What would you like to do?",
            type: 'list',
            choices: [INSTALL_PEER_ADMIN_CARDS,
            new inquirer.Separator(),
            GEN_PEER_ADMIN_CARDS_SINGLE_ORG,
            GEN_PEER_ADMIN_CARDS_MULTI_ORG,
            GEN_PEER_ADMIN_CARDS_CLOUD_MULTI_ORG,
            new inquirer.Separator(),
            // GEN_NW_ADMIN_CARDS_SINGLE_ORG,
            // GEN_NW_ADMIN_CARDS_MULTI_ORG,
            // new inquirer.Separator(),
            LIST_CARDS,
            DELETE_ALL_CARDS,
            new inquirer.Separator(),
            EXIT]
        }
    ];

    // Let's prompt
    inquirer.prompt(question).then(function(result){
        switch(result.action){
            case INSTALL_PEER_ADMIN_CARDS: installPeerAdminCards(); break;
            case GEN_PEER_ADMIN_CARDS_MULTI_ORG: genMultiOrgPeerAdminCards(); break;
            case GEN_PEER_ADMIN_CARDS_SINGLE_ORG: genSingleOrgPeerAdminCards(); break;
            case GEN_PEER_ADMIN_CARDS_CLOUD_MULTI_ORG: genCloudMultiOrgPeerAdminCards(); break;
            // case GEN_NW_ADMIN_CARDS_SINGLE_ORG: genNwAdminCards('single-org.yaml'); break;
            // case GEN_NW_ADMIN_CARDS_MULTI_ORG: genNwAdminCards('multi-org.yaml'); break;
            case DELETE_ALL_CARDS: deleteAllCards(); break;
            case LIST_CARDS: listCards(); break;
            case HELP_CLEANUP: helpCleanup(); break;
            case EXIT: process.exit(0);
        }
    });
}
/**
 * 1. Picks up the card file names from the ../cards folder
 *      2. For each card file check if there is a card with the clashing name if yes delete it
 *      3. Import the card
 * In effect any card file placed in the cards folder will get imported with this option
 */
function installPeerAdminCards(){
    // Read the cards folder
    var files = fs.readdirSync(CARDS_FOLDER);
    
    var filesComposer = fs.readdirSync(COMPOSER_CARD_FOLDER)
    //console.log(filesComposer)
    for(var i=0; i< files.length;i++){
        if(!files[i].endsWith(".card")){
            files[i]="IGNORE";
            continue;
        }
        // Delete card if its already installed
        let installedCardIndex=getCardExist(filesComposer,files[i])
        if(installedCardIndex >= 0){
            // Delete the card
            console.log("Deleting existing card: "+ filesComposer[installedCardIndex]);
            fsextra.removeSync( COMPOSER_CARD_FOLDER+"/"+filesComposer[installedCardIndex]);
        }
        // Install the card now
        installCard(files[i]);
    }
}

function installCard(file){
    var yourscript = exec('composer card import -f '+ CARDS_FOLDER+"/"+file,
        (error, stdout, stderr) => {
            //console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            } else {
                console.log("Successfully Installed: "+file);
            }
        });
}
function getCardExist(filesComposer, cardFile){
    for(var j=0; j < filesComposer.length;j++){
        let cfile=cardFile.replace(".card","")
        //console.log(cfile, filesComposer[j])
        if(filesComposer[j].startsWith(cfile)){
            return j;
        }
    }
    return -1;
}

function genNwAdminCards(envFile){
    //console.log('pppppp',envFile)
    exec('node gen-networkadmin-cards.js '+envFile,
    (error, stdout, stderr) => {
        console.log(`${stdout}`);
        console.log(`${stderr}`);
        if (error !== null) {
            console.log(`exec error: ${error}`);
        }
    });
    
}

/** Generates the cards from the profile env/single-org.yaml */
function genSingleOrgPeerAdminCards(){
    cleanupCardsFolder()
    exec('node gen-peeradmin-cards.js single-org.yaml',
    (error, stdout, stderr) => {
        console.log(`${stdout}`);
        console.log(`${stderr}`);
        if (error !== null) {
            console.log(`exec error: ${error}`);
        }
    });
}

/** Generates the cards from the profile env/multi-org.yaml */
function genMultiOrgPeerAdminCards(){
    exec('node gen-peeradmin-cards.js multi-org.yaml',
    (error, stdout, stderr) => {
        console.log(`${stdout}`);
        console.log(`${stderr}`);
        if (error !== null) {
            console.log(`exec error: ${error}`);
        }
    });
}

/** Generates the cards from the profile env/multi-org.yaml */
function genCloudMultiOrgPeerAdminCards(){
    exec('node gen-peeradmin-cards.js multi-org.cloud.yaml',
    (error, stdout, stderr) => {
        console.log(`${stdout}`);
        console.log(`${stderr}`);
        if (error !== null) {
            console.log(`exec error: ${error}`);
        }
    });
}

function cleanupCardsFolder(){
    var files = fs.readdirSync(CARDS_FOLDER);
    for(var i=0; i< files.length;i++){
        if(files[i].endsWith(".card")){
            fs.unlink(CARDS_FOLDER+"/"+files[i], ()=>{})
        }
    }
    console.log("Deleted files from local Cards folder!!!")
}

/** List the business cards */
function listCards(){
    const CardList = require('composer-cli').Card.List;

    let options = {
        //card: 'admin@tutorial-network'
    };

    CardList.handler(options);
}

/** Delete all of the business cards */
function deleteAllCards(){
    // Simply remove the .composer folder if it exists
    var composerPath = os.homedir()+"/.composer";
    if(fs.existsSync(composerPath)){
        fsextra.remove(composerPath, err =>{
            if(err){
              return  console.log(chalk.red("Error removing the cards!!!"));
            }
            console.log(chalk.green('Removed all cards!!'));
        })
    }
}
