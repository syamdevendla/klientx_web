'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const firebase = admin.initializeApp();
const db = firebase.firestore()

const {
    RtcTokenBuilder,
    RtcRole,
    RtmTokenBuilder
} = require('agora-token')


exports.deleteCompleteChatRoomMediaDataForAgents = functions.firestore.document('/agentmessages/{messageId}')
    .onDelete(async(snap, context) => {
        const { messageId } = context.params;
        const bucket = firebase.storage().bucket();
        return bucket.deleteFiles({
            prefix: `+00_AGENT_CHAT_MEDIA/${messageId}`
        });

    });
    exports.deleteCompleteChatRoomMediaDataForCustomers = functions.firestore.document('/customermessages/{messageId}')
    .onDelete(async(snap, context) => {
        const { messageId } = context.params;
        const bucket = firebase.storage().bucket();
        return bucket.deleteFiles({
            prefix: `+00_CUSTOMER_CHAT_MEDIA/${messageId}`
        });

    });
exports.deleteChatroomMessagesForAgents = functions.firestore.document('/agentmessages/{messageId}')
    .onDelete(async(snap, context) => {
        const { messageId } = context.params;
        return db.collection(`agentmessages/${messageId}/${messageId}`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Chat Sub Collection successfully');
            });
    });
    exports.deleteChatroomMessagesForCustomers = functions.firestore.document('/customermessages/{messageId}')
    .onDelete(async(snap, context) => {
        const { messageId } = context.params;
        return db.collection(`customermessages/${messageId}/${messageId}`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Chat Sub Collection successfully');
            });
    });
exports.deleteGroupMediaDataForAgents = functions.firestore.document('/agentgroups/{groupId}')
    .onDelete(async(snap, context) => {
        const { groupId } = context.params;
        const bucket = firebase.storage().bucket();
        return bucket.deleteFiles({
            prefix: `+00_AGENT_GROUP_MEDIA/${groupId}`
        });

    });

    exports.deleteMediaDataForTicket= functions.firestore.document('/tickets/{ticketId}')
    .onDelete(async(snap, context) => {
        const { ticketId } = context.params;
        const bucket = firebase.storage().bucket();
        return bucket.deleteFiles({
            prefix: `+00_TICKET_MEDIA/${ticketId}`
        });

    });
exports.deleteChatMessagesForTicket = functions.firestore.document('/tickets/{ticketId}')
    .onDelete(async(snap, context) => {
        const { ticketId } = context.params;
        return db.collection(`tickets/${ticketId}/ticketChats`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Ticket Messages successfully');
            });
    });
exports.deleteChatMessagesForTicketEventLive = functions.firestore.document('/tickets/{ticketId}')
    .onDelete(async(snap, context) => {
        const { ticketId } = context.params;
        return db.collection(`tickets/${ticketId}/liveEvents`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Ticket liveevent Doc successfully');
            });
    });
exports.deleteGroupChatMessagesForAgents = functions.firestore.document('/agentgroups/{groupId}')
    .onDelete(async(snap, context) => {
        const { groupId } = context.params;
        return db.collection(`agentgroups/${groupId}/groupChats`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Group Sub Collection successfully');
            });
    });

    exports.deleteGroupMediaDataForCustomers= functions.firestore.document('/customergroups/{groupId}')
    .onDelete(async(snap, context) => {
        const { groupId } = context.params;
        const bucket = firebase.storage().bucket();
        return bucket.deleteFiles({
            prefix: `+00_CUSTOMER_GROUP_MEDIA/${groupId}`
        });

    });
    exports.deleteGroupChatMessagesForCustomers= functions.firestore.document('/customergroups/{groupId}')
    .onDelete(async(snap, context) => {
        const { groupId } = context.params;
        return db.collection(`customergroups/${groupId}/groupChats`)
            .get()
            .then(res => {

                res.forEach(element => {
                    element.ref.delete();
                });
                console.log('Deleted Group Sub Collection successfully');
            });
    });

// exports.deleteStatus = functions.firestore.document('/status/{statusId}')
//     .onDelete(async(snap, context) => {
//         const { statusId } = context.params;
//         const bucket = firebase.storage().bucket();
//         return bucket.deleteFiles({
//             prefix: `+00_STATUS_MEDIA/${statusId}`
//         });

//     });
// exports.deleteBroadcast = functions.firestore.document('/broadcasts/{broadcastId}')
//     .onDelete(async(snap, context) => {
//         const { broadcastId } = context.params;
//         const bucket = firebase.storage().bucket();
//         return bucket.deleteFiles({
//             prefix: `+00_BROADCAST_MEDIA/${broadcastId}`
//         });

//     });

// exports.deleteBroadcastChatDocs = functions.firestore.document('/broadcasts/{broadcastId}')
//     .onDelete(async(snap, context) => {
//         const { broadcastId } = context.params;
//         return db.collection(`broadcasts/${broadcastId}/broadcastChats`)
//             .get()
//             .then(res => {

//                 res.forEach(element => {
//                     element.ref.delete();
//                 });
//                 console.log('Deleted Broadcast Sub Collection successfully');
//             });
//     });

// ---------------  NEW MESSAGE NOTIFICATION ---------------------



exports.onNewTicketChatMessageEvent = functions.firestore.document('/tickets/{ticketId}/{ticketChats}/{timestamp}')
    .onCreate(async(snap, context) => {
        const message = snap.data();
let agentmessageRecipients = message['tL1'];
let isSendToCustomer= message['sf'].includes(0);
let isSendToAgent= message['sf'].includes(1);
         let payload;
       const multiLangNotifMap = {
            "ntm": "New text message",
            "nim": "📷 Photo",
            "nvm": "🎥 Video",
            "nam": "🎙️ Recording",
            "ncm": "👤 Contact shared",
            "ndm": "📄 Document",
            "nlm": "📍 Current Location shared",
            "niac": "📞 Incoming Audio Call",
            "nivc": "🎥 Incoming Video Call",
            "ce": "Call Ended",
            "mc": "Missed Call",
            "aorc": "Accept Or Reject the Call",
            "cr": " all Rejected",
            "nr":"New Message In Ticket ID:",
            "cd":"Customer",
            "ag":"Agent",
            "rbTC":"New Ticket created",
            "rbTDU":"Ticket Description updated",
            "rbTCL":"Ticket Closed",
            "rbTA":"Agent(s) assigned in ticket",
            "rbRTC":"Request to Close Ticket",
            "rbRA":"Require Attention in Ticket",
            "rbTRO":"Ticket Re-Opened",
            "rbTCDC":"Ticket Close denied by Customer",
            "rbTCDA":"Ticket Close denied by Agent",
            "rbAMR":"Attention mark removed",
            "rbAAC":"Agent assigned for Call",
            "rbARC":"Agent Removed from Call assigned",
            "rbNCT":"New Call In Ticket",
            "TkID":"Ticket ID",
      
        };
//  0    text     ,
// 1  image,
// 2  video,
//  3 doc,
//  4 location,
//  5 contact,
//  6 audio,
//  7 rROBOTticketcreated,
//  8 rROBOTticketdescriptionupdated,
//  9 rROBOTticketclosed,
//  10 rROBOTagentsassigned,
//  11 rROBOTrequestedtoclose,
//  12 rROBOTrequireattention,
//  13 rROBOTticketreopened,
//  14 rROBOTclosingDeniedByCustomer,
//  15 rROBOTclosingDeniedByAgent,
//  16 rROBOTremovettention,
//  17 rROBOTassignAgentForACustomerCall,
//  18 rROBOTremoveAssignAgentForACustomerCall,
//  19 rROBOTcallHistory,


let sender = message.ti1==0?multiLangNotifMap['cd']:multiLangNotifMap['ag'];
if (message['ty'] == 0||message['ty'] == 1||message['ty'] == 2||message['ty'] == 3||message['ty'] == 4||message['ty'] == 5||message['ty'] == 6) {
      // New text message & all type of media messages
     payload = {
            notification: {
                title: multiLangNotifMap['nr']+' '+message.idf,
                body: sender+ ':  ' + (message.ty == 0 ? multiLangNotifMap['ntm'] : message.ty == 1 ? multiLangNotifMap['nim'] : message.ty == 2 ? multiLangNotifMap['nvm'] : message.ty == 3 ? multiLangNotifMap['ndm'] : message.ty == 4 ? multiLangNotifMap['nlm'] : message.ty == 5 ? multiLangNotifMap['ncm'] : message.ty == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm']),
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                priority: "high",
                sound: 'default',
            },
            data: {
                'titleMultilang':multiLangNotifMap['nr']+' '+message.idf,
                'bodyMultilang': sender+ ':  ' + (message.ty == 0 ? multiLangNotifMap['ntm'] : message.ty == 1 ? multiLangNotifMap['nim'] : message.ty == 2 ? multiLangNotifMap['nvm'] : message.ty == 3 ? multiLangNotifMap['ndm'] : message.ty == 4 ? multiLangNotifMap['nlm'] : message.ty == 5 ? multiLangNotifMap['ncm'] : message.ty == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm']),
                'title': multiLangNotifMap['nr']+' '+message.idf,
                'body': sender+ ':  ' + (message.ty == 0 ? multiLangNotifMap['ntm'] : message.ty == 1 ? multiLangNotifMap['nim'] : message.ty == 2 ? multiLangNotifMap['nvm'] : message.ty == 3 ? multiLangNotifMap['ndm'] : message.ty == 4 ? multiLangNotifMap['nlm'] : message.ty == 5 ? multiLangNotifMap['ncm'] : message.ty == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm']),
                'ticketIDfiltered':message.idf,
                'notificationEventType':'TICKET_EVENTS',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
        };
} else if(message['ty'] == 7||message['ty'] == 8||message['ty'] == 9||message['ty'] == 10||message['ty'] == 11||message['ty'] == 12||message['ty'] == 13||message['ty'] == 14||message['ty'] == 15||message['ty'] == 16||message['ty'] == 17||message['ty'] == 18||message['ty'] == 19) {
          // All robotic automatated messages
           payload = {

            notification: {
                title: message.ty == 7 ?multiLangNotifMap['rbTC'] :message.ty == 8 ?multiLangNotifMap['rbTDU'] :message.ty == 9 ?multiLangNotifMap['rbTCL'] :message.ty == 10 ?multiLangNotifMap['rbTA'] :message.ty == 11 ?multiLangNotifMap['rbRTC'] :message.ty == 12 ?multiLangNotifMap['rbRA'] :message.ty == 13 ?multiLangNotifMap['rbTRO']:message.ty == 14 ?multiLangNotifMap['rbTCDC']:message.ty == 15 ?multiLangNotifMap['rbTCDA']:message.ty == 16 ?multiLangNotifMap['rbAMR']:message.ty == 17 ?multiLangNotifMap['rbAAC']:message.ty == 18 ?multiLangNotifMap['rbARC']:message.ty == 19 ?multiLangNotifMap['rbNCT']:"Ticket notification",
                body: multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                priority: "high",
                sound: 'default',
            },
            data: {
                'titleMultilang':message.ty == 7 ?multiLangNotifMap['rbTC'] :message.ty == 8 ?multiLangNotifMap['rbTDU'] :message.ty == 9 ?multiLangNotifMap['rbTCL'] :message.ty == 10 ?multiLangNotifMap['rbTA'] :message.ty == 11 ?multiLangNotifMap['rbRTC'] :message.ty == 12 ?multiLangNotifMap['rbRA'] :message.ty == 13 ?multiLangNotifMap['rbTRO']:message.ty == 14 ?multiLangNotifMap['rbTCDC']:message.ty == 15 ?multiLangNotifMap['rbTCDA']:message.ty == 16 ?multiLangNotifMap['rbAMR']:message.ty == 17 ?multiLangNotifMap['rbAAC']:message.ty == 18 ?multiLangNotifMap['rbARC']:message.ty == 19 ?multiLangNotifMap['rbNCT']:"Ticket notification",
                'bodyMultilang':    multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                'title':message.ty == 7 ?multiLangNotifMap['rbTC'] :message.ty == 8 ?multiLangNotifMap['rbTDU'] :message.ty == 9 ?multiLangNotifMap['rbTCL'] :message.ty == 10 ?multiLangNotifMap['rbTA'] :message.ty == 11 ?multiLangNotifMap['rbRTC'] :message.ty == 12 ?multiLangNotifMap['rbRA'] :message.ty == 13 ?multiLangNotifMap['rbTRO']:message.ty == 14 ?multiLangNotifMap['rbTCDC']:message.ty == 15 ?multiLangNotifMap['rbTCDA']:message.ty == 16 ?multiLangNotifMap['rbAMR']:message.ty == 17 ?multiLangNotifMap['rbAAC']:message.ty == 18 ?multiLangNotifMap['rbARC']:message.ty == 19 ?multiLangNotifMap['rbNCT']:"Ticket notification",
                'body': multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                'ticketIDfiltered':message.idf,
                    'notificationEventType':'TICKET_EVENTS',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
        };
}else{
     payload = {

            notification: {
                title: "New notification",
                body: multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                priority: "high",
                sound: 'default',
            },
            data: {
                'titleMultilang': "New notification",
                'bodyMultilang':   multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                'title': "New notification",
                'body': multiLangNotifMap['TkID']+": "+message.idf+" | "+message.tn,
                'ticketIDfiltered':message.idf,
                    'notificationEventType':'TICKET_EVENTS',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
        };

}
        
        var options = {
            priority: 'high',
            contentAvailable: true,

        };
       
 if (isSendToAgent==true) {
agentmessageRecipients.forEach(async function(element) {
    if (message.tsb!=element) {
        await admin.messaging().sendToTopic(`${element}`, payload, options);
 return console.log(`Sent to ticket agent : ${element} in Ticket ID: ${message.idf}`); 
    }

});
    }
    if (isSendToCustomer==true&&message.tsb!=message.mp) {
         await admin.messaging().sendToTopic(`${message.mp}`, payload, options);
         return console.log(`Sent to ticket customer : ${message.mp} in Ticket ID: ${message.idf}`);
    }
       
    });



exports.sendNewMessageNotificationForAgentsToAgentChat = functions.firestore.document('/agentmessages/{chatId}/{chat_id}/{timestamp}')
    .onCreate(async(snap, context) => {


        const message = snap.data();
        // Get the list of device notification tokens.
        const getRecipientPromise = admin.firestore().collection('agents').doc(message.to).get();

        // The snapshot to the user's tokens.
        let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens =message.iMu==true?[]: recipient.data().nts ;
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0 ) {
            return console.log('There are no notification tokens to send to.');
        }
        // if (recipient.data().lastSeen === true) {
        //     return console.log('User is Online. So no need to send message.');
        // }
        let payload;
        let options;
        // Notification details.
        if (isMultilangNotificationEnabled == true) {
            //----MultiLang New Message Notification --------------------------------------------------------------------------------                

            payload = {
                notification: {
                    title: message.sname || message.fm,
                    body: message.mtp == 0 ? multiLangNotifMap['ntm'] : message.mtp == 1 ? multiLangNotifMap['nim'] : message.mtp == 2 ? multiLangNotifMap['nvm'] : message.mtp == 3 ? multiLangNotifMap['ndm'] : message.mtp == 4 ? multiLangNotifMap['nlm'] : message.mtp == 5 ? multiLangNotifMap['ncm'] : message.mtp == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'default',
                },
                data: {

                    'titleMultilang': message.sname || message.fm,
                    'bodyMultilang': message.mtp == 0 ? multiLangNotifMap['ntm'] : message.mtp == 1 ? multiLangNotifMap['nim'] : message.mtp == 2 ? multiLangNotifMap['nvm'] : message.mtp == 3 ? multiLangNotifMap['ndm'] : message.mtp == 4 ? multiLangNotifMap['nlm'] : message.mtp == 5 ? multiLangNotifMap['ncm'] : message.mtp == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm'],
                    'title': 'You have new message(s)',
                    'body': 'New message(s) recieved.',
                    'peerid': message.fm,
                    'agent_message_chat_id': message.id,
                        'notificationEventType':'AGENT_MESSAGES',
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                },

            }
            options = {
                priority: 'high',
                contentAvailable: true,

            };


        } else {
            //----non-MultiLang New Message Notification --------------------------------------------------------------------------------                

            payload = {
                notification: {
                    title: 'You have new message(s)',
                    body: 'New message(s) recieved.',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'default',
                },
                data: {
                    'titleMultilang': 'You have new message(s)',
                    'bodyMultilang': 'New message(s) recieved.',
                    'title': 'You have new message(s)',
                    'body': 'New message(s) recieved.',
                    'peerid': message.fm,
                    'agent_message_chat_id': message.id,
                                'notificationEventType':'AGENT_MESSAGES',
                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                },

            }
            options = {
                priority: 'high',
                contentAvailable: true,

            };


        }

        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload, options);
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                console.error('Failure sending notification to', tokens[index], error);
                // Cleanup the tokens who are not registered anymore.
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(tokens[index]);
                }
            }
        });
        return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
    });






exports.recieveGroupMsgNotificationForAgents = functions.firestore.document('/agentgroups/{groupId}/groupChats/{chatId}')
    .onCreate(async(snap, context) => {
        const message = snap.data();
  const groupId= context.params.groupId;
        const multiLangNotifMap = {
            "ntm": "New text message",
            "nim": "📷 Photo",
            "nvm": "🎥 Video",
            "nam": "🎙️ Recording",
            "ncm": "👤 Contact shared",
            "ndm": "📄 Document",
            "nlm": "📍 Current Location shared",
            "niac": "📞 Incoming Audio Call",
            "nivc": "🎥 Incoming Video Call",
            "ce": "Call Ended",
            "mc": "Missed Call",
            "aorc": "Accept Or Reject the Call",
            "cr": " all Rejected"
        };
        // Notification details.
        const payload = {
            notification: {
                title: message.gn,
                body: message.sname + ':  ' + (message.type == 0 ? multiLangNotifMap['ntm'] : message.type == 1 ? multiLangNotifMap['nim'] : message.type == 2 ? multiLangNotifMap['nvm'] : message.type == 3 ? multiLangNotifMap['ndm'] : message.type == 4 ? multiLangNotifMap['nlm'] : message.type == 5 ? multiLangNotifMap['ncm'] : message.type == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm']),
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                priority: "high",
                sound: 'default',
            },
            data: {
                'titleMultilang': message.gn,
                'bodyMultilang': message.sname + ':  ' + (message.type == 0 ? multiLangNotifMap['ntm'] : message.type == 1 ? multiLangNotifMap['nim'] : message.type == 2 ? multiLangNotifMap['nvm'] : message.type == 3 ? multiLangNotifMap['ndm'] : message.type == 4 ? multiLangNotifMap['nlm'] : message.type == 5 ? multiLangNotifMap['ncm'] : message.type == 6 ? multiLangNotifMap['nam'] : multiLangNotifMap['ntm']),
                'title': 'New message in Group',
                'body': 'New message(s) recieved.',
                'groupid':groupId,
                      'notificationEventType':'AGENT_GROUP_MESSAGES',
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },

        };
        var options = {
            priority: 'high',
            contentAvailable: true,

        };
        await admin.messaging().sendToTopic(`GROUP${message.gidf}`, payload, options);
    });



    //---------------MANAGE TOKENS subscription--------------------



exports.manageGroupTokens = functions.firestore.document('/tempUnsubscribeTokens/{id}')
    .onCreate(async(snap, context) => {
        const message = snap.data();
        // These registration tokens come from the client FCM SDKs.
        const registrationTokens = message.nts;

      


        if (message.type == 'subscribe') {
            // Subscribe the devices corresponding to the registration tokens to the
            // topic.
            // admin.messaging().subscribeToTopic(registrationTokens, `GROUP${message.gidf}`)
            //     .then((response) => {
            //         // See the MessagingTopicManagementResponse reference documentation
            //         // for the contents of response.
            //         console.log('Successfully subscribed to topic:', response);
            //     })
            //     .catch((error) => {
            //         console.log('Error subscribing to topic:', error);
            //     });
        } else if (message.type == 'unsubscribe') {
            // Unsubscribe the devices corresponding to the registration tokens from
            // the topic.
            // admin.messaging().unsubscribeFromTopic(registrationTokens, `GROUP${message.gidf}`)
            //     .then((response) => {
            //         // See the MessagingTopicManagementResponse reference documentation
            //         // for the contents of response.
            //         console.log('Successfully unsubscribed from topic:', response);
            //     })
            //     .catch((error) => {
            //         console.log('Error unsubscribing from topic:', error);
            //     });



        }


    });

// -------- ACTIVITY NOTIFICATION FOR USER APP ------------------------
exports.singleAgentNotification = functions.firestore.document('/agents/{userId}/agentnotifications/agentnotifications')
    .onUpdate(async(change, context) => {
        const message = change.after.data();
        const id= context.params.userId;
        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                         "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "eventid":"5",
          "notificationEventType":'SINGLE_AGENT_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "image": message['xa5'],
                            "eventid":"5",
                                     "notificationEventType":'SINGLE_AGENT_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to single user
            await admin.messaging().sendToTopic(id, payload, options);

        }
    });


exports.singleCustomerNotification = functions.firestore.document('/customers/{userId}/customernotifications/customernotifications')
    .onUpdate(async(change, context) => {
        const message = change.after.data();
        const id= context.params.userId;
        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "eventid":"6",
         "notificationEventType":'SINGLE_CUSTOMER_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "image": message['xa5'],
                                "notificationEventType":'SINGLE_CUSTOMER_NOTIFICATION',
                            "eventid":"6",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to single user
            await admin.messaging().sendToTopic(id, payload, options);

        }
    });












//---------------All Admin notification for Admin App--------------------

exports.allAdminNotification = functions.firestore.document('/adminapp/adminnotifications')
    .onUpdate(async(change, context) => {
        const message = change.after.data();

        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                                "notificationEventType":'ALL_ADMIN_NOTIFICATION',
    "eventid":"2",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "image": message['xa5'],
                                "notificationEventType":'ALL_ADMIN_NOTIFICATION',
                            "eventid":"2",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to all subscribed.
            await admin.messaging().sendToTopic('Admin', payload, options);

        }
    });

 exports.allActivityNotification = functions.firestore.document('/adminapp/history')
    .onUpdate(async(change, context) => {
        const message = change.after.data();

        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "eventid":"1",
        "notificationEventType":'ALL_ACTIVITY_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "image": message['xa5'],
                                "notificationEventType":'ALL_ACTIVITY_NOTIFICATION',
                            "eventid":"1",
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to all subscribed.
            await admin.messaging().sendToTopic('Activities', payload, options);

        }
    });


 exports.allAgentsNotification = functions.firestore.document('/userapp/agentnotifications')
    .onUpdate(async(change, context) => {
        const message = change.after.data();

        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "eventid":"3",
        "notificationEventType":'ALL_AGENTS_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "image": message['xa5'],
                            "eventid":"3",
                                   "notificationEventType":'ALL_AGENTS_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to all subscribed.
            await admin.messaging().sendToTopic('AGENTS', payload, options);

        }
    });

     exports.allCustomersNotification = functions.firestore.document('/userapp/customernotifications')
    .onUpdate(async(change, context) => {
        const message = change.after.data();

        if (message['xa4'] === 'NOPUSH') {
            return console.log('Skipped Notification as it is not meant to be PUSHED');
        } else if (message['xa4'] === 'PUSH') {
            let payload;
            // Notification details.

            if (message['xa5'] == null||message['xa5'] == "") {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],

                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                        "eventid":"4",
    "notificationEventType":'ALL_CUSTOMERS_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            } else {
                payload = {
                    notification: {
                        title: message['xa2'],
                        body: message['xa3'],
                        image: message['xa5'],
                        click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        priority: "high",
                        sound: 'default',
                    },
                    data: {
                        "body": message['xa3'],
                        "title": message['xa2'],
                        "image": message['xa5'],
                               "titleMultilang":message['xa2'],
                "bodyMultilang":message['xa3'],
                            "eventid":"4",
                                      "notificationEventType":'ALL_CUSTOMERS_NOTIFICATION',
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    },
                }
            }

            var options = {
                priority: 'high',
                contentAvailable: true,

            };
            // Send notifications to all subscribed.
            await admin.messaging().sendToTopic('CUSTOMERS', payload, options);

        }
    });







exports.newIncomingCallForAgents = functions.firestore.document('/agents/{agentId}/callhistory/{callId}')
    .onCreate(async(snap, context) => {
        const message = snap.data();

        if (message['TYPE'] === 'OUTGOING') {
            return console.log('Skipped Notification as it is Outgoing Call.');
        } else {
            // Get the list of device notification tokens.
            const getRecipientPromise = admin.firestore().collection('agents').doc(message['TARGET']).get();

              // The snapshot to the user's tokens.
        let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        // if (recipient.data().lastSeen === true) {
        //     return console.log('User is Online. So no need to send message.');
        // }
        let payload;
        
            // Notification details.
            if (isMultilangNotificationEnabled == true) {
                //----MultiLang Call Notification --------------------------------------------------------------------------------                

                if (message['ISVIDEOCALL'] == true) {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: multiLangNotifMap['nivc'],
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['nivc'],
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                 'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: multiLangNotifMap['nivc'],
                                body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf'

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['nivc'],
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };
                } else {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: multiLangNotifMap['niac'],
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['niac'],
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: multiLangNotifMap['niac'],
                                body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf',

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['niac'],
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };

                }
            } else {
                //----Non - multiLang Call Notification --------------------------------------------------------------------------------
                if (message['ISVIDEOCALL'] == true) {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: 'Incoming Video Call...',
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf',

                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Video Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: 'Incoming Video Call...',
                                body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf',

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Video Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };
                } else {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: 'Incoming Audio Call...',
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Audio Call...',
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: 'Incoming Audio Call...',
                                body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf'
                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Audio Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };

                }

            }
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload, options);
            // For each message check if there was an error.
            const tokensToRemove = [];
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to', tokens[index], error);
                    // Cleanup the tokens who are not registered anymore.
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        tokensToRemove.push(tokens[index]);
                    }
                }
            });
            return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
        }
    });


exports.newIncomingCallForCustomers = functions.firestore.document('/customers/{customerId}/callhistory/{callId}')
    .onCreate(async(snap, context) => {
        const message = snap.data();

        if (message['TYPE'] === 'OUTGOING') {
            return console.log('Skipped Notification as it is Outgoing Call.');
        } else {
            // Get the list of device notification tokens.
            const getRecipientPromise = admin.firestore().collection('customers').doc(message['TARGET']).get();

              // The snapshot to the user's tokens.
        let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        // if (recipient.data().lastSeen === true) {
        //     return console.log('User is Online. So no need to send message.');
        // }
        let payload;
        
            // Notification details.
            if (isMultilangNotificationEnabled == true) {
                //----MultiLang Call Notification --------------------------------------------------------------------------------                

                if (message['ISVIDEOCALL'] == true) {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: multiLangNotifMap['nivc'],
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['nivc'],
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                 'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: multiLangNotifMap['nivc'],
                                body:message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf'

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['nivc'],
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };
                } else {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: multiLangNotifMap['niac'],
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['niac'],
                                'bodyMultilang':message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body':message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: multiLangNotifMap['niac'],
                                body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf',

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': multiLangNotifMap['niac'],
                                'bodyMultilang':message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body':message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };

                }
            } else {
                //----Non - multiLang Call Notification --------------------------------------------------------------------------------
                if (message['ISVIDEOCALL'] == true) {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: 'Incoming Video Call...',
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf',

                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Video Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: 'Incoming Video Call...',
                                body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf',

                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Video Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Video Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };
                } else {
                    if (recipient.data().ddt['ost'] == 'android') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            // notification: {
                            //     title: 'Incoming Audio Call...',
                            //     body: recipient.data().nickname,
                            //     click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            //     priority: 'high',
                            //     sound: 'ringtone.caf'
                            // },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Audio Call...',
                                'bodyMultilang':  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    } else if (recipient.data().ddt['ost'] == 'ios') {
                        payload = {
                            //  Disabled the notification property so that onbackgroundmessage can be triggered--------
                            notification: {
                                title: 'Incoming Audio Call...',
                                body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                priority: 'high',
                                sound: 'ringtone.caf'
                            },
                            data: {
                                'dp': message['DP'],
                                'titleMultilang': 'Incoming Audio Call...',
                                'bodyMultilang': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                'title': 'Incoming Audio Call...',
                                'body': message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                         'notificationEventType':'CALLS',
                                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            }

                        }
                    }

                    var options = {
                        priority: 'high',
                        contentAvailable: true,

                    };

                }

            }
            // Send notifications to all tokens.
            const response = await admin.messaging().sendToDevice(tokens, payload, options);
            // For each message check if there was an error.
            const tokensToRemove = [];
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending notification to', tokens[index], error);
                    // Cleanup the tokens who are not registered anymore.
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        tokensToRemove.push(tokens[index]);
                    }
                }
            });
            return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
        }
    });

exports.callRejectedFirstTimeForAgents = functions.firestore.document('/agents/{agentId}/recent/callended')
    .onCreate(async(snap, context) => {
        const message = snap.data();

        // if (message['TYPE'] === 'OUTGOING') {
        //     return console.log('Skipped Notification as it is Outgoing Call.');
        // } else {


        // Get the list of device notification tokens.
        const getRecipientPromise = admin.firestore().collection('agents').doc(message['id']).get();

         let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        let payload;
        // Notification details.
        if (isMultilangNotificationEnabled == true) {
            //----MultiLang Call Rejected  Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: multiLangNotifMap['cr'],
                    body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'

                },

                data: {
                    "titleMultilang": multiLangNotifMap['cr'],
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Call Ended',
                    "body": 'Incoming Call ended',
                              "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
            }
        } else {
            //----Non - multiLang Call Rejected Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: 'Call Ended',
                    body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'


                },

                data: {
                    "titleMultilang": 'Call Ended',
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Call Ended',
                    "body": message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                             "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",


                },
            }



        }
        var options = {
            priority: 'high',
            contentAvailable: true,

        };



        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload, options);
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                console.error('Failure sending notification to', tokens[index], error);
                // Cleanup the tokens who are not registered anymore.
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(tokens[index]);
                }
            }
        });
         return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
        // }
    });


exports.callRejectedFirstTimeForACustomers = functions.firestore.document('/customers/{customerId}/recent/callended')
    .onCreate(async(snap, context) => {
        const message = snap.data();

        // if (message['TYPE'] === 'OUTGOING') {
        //     return console.log('Skipped Notification as it is Outgoing Call.');
        // } else {


        // Get the list of device notification tokens.
        const getRecipientPromise = admin.firestore().collection('customers').doc(message['id']).get();

         let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        let payload;
        // Notification details.
        if (isMultilangNotificationEnabled == true) {
            //----MultiLang Call Rejected  Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: multiLangNotifMap['cr'],
                    body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'

                },

                data: {
                    "titleMultilang": multiLangNotifMap['cr'],
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Call Ended',
                    "body": 'Incoming Call ended',
                              "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
            }
        } else {
            //----Non - multiLang Call Rejected Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: 'Call Ended',
                    body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'


                },

                data: {
                    "titleMultilang": 'Call Ended',
                    "bodyMultilang": message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Call Ended',
                    "body":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                             "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",


                },
            }



        }
        var options = {
            priority: 'high',
            contentAvailable: true,

        };



        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload, options);
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                console.error('Failure sending notification to', tokens[index], error);
                // Cleanup the tokens who are not registered anymore.
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(tokens[index]);
                }
            }
        });
         return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
        // }
    });



exports.callRejectedNotFirstTimeForAgents = functions.firestore.document('/agents/{agentId}/recent/callended')
    .onUpdate(async(change, context) => {
        const message = change.after.data();


        const getRecipientPromise = admin.firestore().collection('agents').doc(message['id']).get();

          let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        let payload;
        // Notification details.

        if (isMultilangNotificationEnabled == true) {
            //----MultiLang Call Ended Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: multiLangNotifMap['mc'],
                    body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'

                },

                data: {
                    "titleMultilang": multiLangNotifMap['mc'],
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Missed Call',
                    "body":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                   "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
            }
        } else {
            //----Non - multiLang Call Ended  Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: 'Missed Call',
                    body: message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'


                },

                data: {

                    "titleMultilang": 'Missed Call',
                    "bodyMultilang": message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Missed Call',
                    "body": message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                             "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",


                },
            }



        }

        var options = {
            priority: 'high',
            contentAvailable: true,

        };
        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload, options);
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                console.error('Failure sending notification to', tokens[index], error);
                // Cleanup the tokens who are not registered anymore.
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(tokens[index]);
                }
            }
        });
         return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
       
    });




exports.callRejectedNotFirstTimeForCustomers = functions.firestore.document('/customers/{customerId}/recent/callended')
    .onUpdate(async(change, context) => {
        const message = change.after.data();


        const getRecipientPromise = admin.firestore().collection('customers').doc(message['id']).get();

          let recipient;
        let isMultilangNotificationEnabled;
        let multiLangNotifMap;
        // The array containing all the user's tokens.
        let tokens;

        const results = await Promise.all([getRecipientPromise]);

        recipient = results[0];


        tokens = recipient.data().nts || [];
        isMultilangNotificationEnabled = recipient.data().isMultiLangNotifEnabled || false;
        multiLangNotifMap = recipient.data().notificationsMap || {};
        // Check if there are any device tokens.
        if (tokens.length === 0) {
            return console.log('There are no notification tokens to send to.');
        }
        let payload;
        // Notification details.

        if (isMultilangNotificationEnabled == true) {
            //----MultiLang Call Ended Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: multiLangNotifMap['mc'],
                    body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'

                },

                data: {
                    "titleMultilang": multiLangNotifMap['mc'],
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Missed Call',
                    "body":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                                   "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                },
            }
        } else {
            //----Non - multiLang Call Ended  Notification --------------------------------------------------------------------------------
            payload = {
                notification: {
                    title: 'Missed Call',
                    body:  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                    priority: "high",
                    sound: 'blank.caf'


                },

                data: {

                    "titleMultilang": 'Missed Call',
                    "bodyMultilang":  message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                    "title": 'Missed Call',
                    "body": message['TICKET_ID'] ==null?message['CALLERNAME'] :message['CALLERNAME']+" | Ticket ID: "+message['TICKET_ID'],
                             "notificationEventType":'CALLS',
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",


                },
            }



        }

        var options = {
            priority: 'high',
            contentAvailable: true,

        };
        // Send notifications to all tokens.
        const response = await admin.messaging().sendToDevice(tokens, payload, options);
        // For each message check if there was an error.
        const tokensToRemove = [];
        response.results.forEach((result, index) => {
            const error = result.error;
            if (error) {
                console.error('Failure sending notification to', tokens[index], error);
                // Cleanup the tokens who are not registered anymore.
                if (error.code === 'messaging/invalid-registration-token' ||
                    error.code === 'messaging/registration-token-not-registered') {
                    tokensToRemove.push(tokens[index]);
                }
            }
        });
         return recipient.ref.update({
            nts: tokens.filter((token) => !tokensToRemove.includes(token))
        });
       
    });



exports.createCallsWithTokens = functions.https.onCall(async (data,context)=>{
    try {
        const appId= data.appId
        const appCertificate= data.appCertificate
        const role = RtcRole.PUBLISHER
        const expirationTimeInSeconds = 3600
        const currentTimestamp= Math.floor(Date.now()/1000)
        const privilegeExpired = currentTimestamp + expirationTimeInSeconds
        const uid = 0
        const channelName = Math.floor(Math.random()*100).toString()
        const token = RtcTokenBuilder.buildTokenWithUid(
            appId,
            appCertificate,
            channelName,
            uid,
            role,
            privilegeExpired
        )
          console.log('Successfully generated Token !')
        return {
            data: {
                token: token,
                channelId: channelName
            }
        }

        
    } catch (err) {
        console.log('Failed to generate the agora Token : ',err)
    
    }
})

//  Deploy these cloud functions using Firebase CLI using following command:
// 
//     firebase login
//     firebase deploy --only functions