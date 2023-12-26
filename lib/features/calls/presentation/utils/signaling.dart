// import 'package:flutter/cupertino.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
//
// typedef StreamStateCallback = void Function(MediaStream stream);
//
// class Signaling {
//   //todo Interactive Connectivity Establishment (ICE)
//   // Now, it is not possible to connect two peers with just their IP addresses.
//   // To establish a connection,
//   // we’d have to first pass in the unique address to locate the peer on the internet.
//   // We’d also need a relay server for sharing media (if a P2P connection is not allowed by the router),
//   // and finally, we’d have to get through the firewall.
// //todo ICE is used to find the optimum path for connecting peers. It examines the different ways to do so and chooses the best one.
//   Map<String, dynamic> configuration = {
//     'iceServers': [
//       {
//         'urls': [
//           'stun:stun1.l.google.com:19302',
//           'stun:stun2.l.google.com:19302',
//         ]
//       }
//     ]
//   };
//
//   RTCPeerConnection? peerConnection;
//
//   //todo the videStream
//   MediaStream? localStream;
//   MediaStream? remoteStream;
//
//   String? roomId;
//
//   //todo the text we got it from the frontEnd
//   String? currentRoomText;
//
//   StreamStateCallback? onAddRemoteStream;
//
//   Future<String> createRoom(RTCVideoRenderer remoteRender) async {
//     var payload;
//     //todo firebase
//
//     //todo the secondParameter is the constraint default {}
//     peerConnection = await createPeerConnection(configuration);
//
//     registerPeerConnectionListeners();
//     //todo track the video and audio
//     localStream?.getTracks().forEach((element) {
//       peerConnection?.addTrack(element, localStream!);
//     });
//
//     //todo track any stream for new subscriber
//     peerConnection?.onTrack = (RTCTrackEvent event) {
//       debugPrint('newTrack');
//       event.streams[0].getTracks().forEach((element) {
//         debugPrint('add a track to the remoteStream $element');
//         remoteStream?.addTrack(element);
//       });
//     };
//
//     //todo we create the offer we create the candidate
//     peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       dynamic candidate1 = candidate.toMap();
//       debugPrint('Got Candidate${candidate1}');
//
//       payload['candidate'] = candidate1;
//       //todo store the candidate someWhere
//     };
//
//     //todo this create offer will trigger the onIceCandidate
//     RTCSessionDescription offer = await peerConnection!.createOffer();
//
//     //todo set the sdp session description
//     await peerConnection!.setLocalDescription(offer);
//
// //todo store it someWhere
//     Map<String, dynamic> offer1 = {'offer': offer.toMap()};
//     payload['offer'] = offer1;
//     debugPrint(payload.toString());
//
//
//     //todo give this info to the call event endpoint
//     return 'roomId';
//   }
//
//   void registerPeerConnectionListeners() {
// //todo whenever happen a  ICE state connection change
//     peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
//       debugPrint('Ice Gathering State change $state');
//     };
//
//     peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
//       debugPrint('Connection  State change $state');
//     };
//
//     peerConnection?.onSignalingState = (RTCSignalingState state) {
//       debugPrint('Signaling State change $state');
//     };
//
//     peerConnection?.onAddStream = (MediaStream stream) {
//       debugPrint('AddRemoteStream');
//
//       onAddRemoteStream?.call(stream);
//       remoteStream = stream;
//     };
//   }
//
//   Future<void> joinRoom(String roomId) async {
//     //todo firebase
//
//     //todo create peerConnection with configuration
//     peerConnection = await createPeerConnection(configuration);
//     registerPeerConnectionListeners();
//
//     localStream?.getTracks().forEach((element) {
//       peerConnection?.addTrack(element, localStream!);
//     });
//
//     peerConnection?.onTrack = (RTCTrackEvent event) {
//       debugPrint('newTrack');
//       event.streams[0].getTracks().forEach((element) {
//         debugPrint('add a track to the remoteStream $element');
//         remoteStream?.addTrack(element);
//       });
//     };
//   }
//
//   Future<void> openUserMedia(
//     RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo) async {
//
//     var stream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
//     localVideo.srcObject = stream;
//     remoteVideo.srcObject = await createLocalMediaStream('label');
//   }
// }
