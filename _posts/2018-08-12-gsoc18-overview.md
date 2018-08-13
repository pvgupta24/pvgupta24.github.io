---
layout: post
title: GSoC 2018 with Jitsi - Overview
description: >
  Overview of work done during the Google Summer of Code 2018 with Jitsi.
tags: [gsoc]
---

I was working on enabling translations to different languages with speech-to-text
in [Jitsi-Meet](https://meet.jit.si/) as a part of GSoC 2018 this summer.

Here is the brief description of the work :

### What works now ?
This project allows us to get the speech-to-text results in different target languages for
translation and also to transcribe in different source languages.

After we start the transcription service, we can specify the source language for the participant
in the console by setting the local participant property `transcription_language` to the required
language tag. This sends the speech-to-text transcription results as JSON messages to be displayed
in near real time as subtitles. 

For getting the final results of transcription in a different language, we can set the local participant
property `translation-result` to the required language tag. In this case, the translated results
in the specific language will be shown.

<iframe width="780" height="500" src="https://www.youtube.com/embed/aq8J_g9JgWs?rel=0" frameborder="0"
allow="autoplay; encrypted-media" allowfullscreen></iframe>

The final transcript of the entire meet is also prepared and stored as a `.txt` and `.json` file locally
on the server.
~~~txt
Transcript of conference held at 12 Aug, 2018 in room GSoC-2018-Jitsi@conference.praveen.jitsi.net
Initial people present at 7:35:13 AM:
Praveen

Transcript, started at 7:35:13 AM:
________________________________________________________________________________
<7:35:15 AM> Praveen joined the conference
<7:35:17 AM> Praveen: 
<7:35:26 AM> Praveen: नमस्ते 
<7:35:39 AM> Praveen: आप कैसे हैं
<7:36:11 AM> Praveen: आप उपशीर्षक में अनुवादित पाठ देख सकते हैं 
________________________________________________________________________________


End of transcript at 12 Aug, 2018 7:36:22 AM
~~~

### How does it work ?
After the transcriber joins the Jitsi-Meet conference room as a participant, it starts the transcription
using a transcription service (Currently [Google Cloud Speech-to-text Service](https://cloud.google.com/speech/)).

The results of transcription are forwarded to a Translation Manager which keeps track of the list of
target languages for translation. If these are final transcription results, they are translated using
the [Google Cloud Translation Service](https://cloud.google.com/translate) and sent to the Jitsi-Meet conference as JSON messages.

Jitsi-Meet receives the results in all languages and displays the ones which have the required language tag and ignores the other ones.
Jigasi can be configured to send translation results as plain text messages in the Chatroom but it will flood the Chatroom with messages.

### Technical Aspects
We needed to make changes in the following Jitsi projects for making translations possible :)

#### [Jigasi](https://github.com/jitsi/jigasi)
When the [Transcriber](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/Transcriber.java) joins a conference, it creates a [TranslationManager](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/TranslationManager.java) object with a [TranslationService](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/TranslationService.java).
Currently [GoogleCloudTranslationService](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/GoogleCloudTranslationService.java) is used but other services can be used by implementing `TranslationService`.
The `TranslationManager` keeps a list of [TranslationResultListener](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/TranslationResultListener.java), which is an interface which can be used to decide the way the translation results are to be used.

Once a user changes the preference for the required language in Jitsi Meet, a presence update is notified to the connected participants
including the transcriber [here](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/JvbConference.java#L778).
This is parsed [here](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/TranscriptionGatewaySession.java#L265)
to get the participant and the language tag (either source language which is 'en-US' by default or target language for the participant) and is notified to the TranslationManager which keeps a count of the participants who need a particular language.
If no more participants need a language, it is removed from the list of languages.

Once a TranscriptionResult is formed, the manager is notified about it which uses the translation service to translate in all the required objects and makes a [TranslationResult](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/TranslationResult.java)
for each of the language and notifies all the [TranslationResultListener](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/TranslationResultListener.java).

The [LocalJsonTranscriptHandler](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/LocalJsonTranscriptHandler.java#L236) sends the json of the type `translation-result` to the conference where it is interpreted accordingly.


List of PRs in Jigasi :
* [https://github.com/jitsi/jigasi/pull/111](https://github.com/jitsi/jigasi/pull/111)
* [https://github.com/jitsi/jigasi/pull/124](https://github.com/jitsi/jigasi/pull/124)
* [https://github.com/jitsi/jigasi/pull/127](https://github.com/jitsi/jigasi/pull/127)

I also sent a PR towards the end of the coding period for storing the final transcript
of the meet in all the requested target languages.
The translations are stored in a map in the [Transcript](https://github.com/jitsi/jigasi/blob/master/src/main/java/org/jitsi/jigasi/transcription/Transcript.java).
After a meet is over or the Transcriber is kicked out, the translations are accumulated and formatted,
by translating the transcription speech events whose translations aren't present yet.

* [https://github.com/jitsi/jigasi/pull/130](https://github.com/jitsi/jigasi/pull/130)

#### [Jitsi](https://github.com/jitsi/jitsi)
We needed to add few extensions to the XMPP stanzas :

Message extension for sending the json messages in a different container (than the body which was used previously)
* [https://github.com/jitsi/jitsi/pull/509](https://github.com/jitsi/jitsi/pull/509)

Presence Extensions for sending the language preference of the user. (Both source and target language)
* [https://github.com/jitsi/jitsi/pull/495](https://github.com/jitsi/jitsi/pull/495)
* [https://github.com/jitsi/jitsi/pull/504](https://github.com/jitsi/jitsi/pull/504)

#### [Jitsi-Meet](https://github.com/jitsi/jitsi-meet)
As discussed in the first blog post, I worked on the react feature subtitles (renamed from transcription) to display
transcription messages as subtitles. It was then extended to show the translation results if a target language is selected
from the console with `APP.conference._room.setLocalParticipantProperty('translation_language','hi');` in which case it
uses the json-message  of type translation-result:
```xml
<message ...>
  <json-message ...>
    {
      "type":"translation-result",
      "text":"नमस्ते आप कैसे हैं?",
      "is_interim":false,
      "language":"hi-IN",
      "message_id":"14fcde1c-26f8-4c03-ab06-106abccb510b",
      "event":"SPEECH",
      "participant":{
          "name":"Praveen",
          "id":"d62f8c36"
      },
      "stability":0.0,
      "timestamp":"201-07-10T11:04:05.637Z"
    }
  </json-message>
</message
```
The language tag of the received json is used to show the subtitles only in the desired language.

* [https://github.com/jitsi/jitsi-meet/pull/1914](https://github.com/jitsi/jitsi-meet/pull/1914) (from [this commit](https://github.com/jitsi/jitsi-meet/pull/1914/commits/48e23fee623c587c18ef76bf0f7033bbec7b9f42))
* [https://github.com/jitsi/jitsi-meet/pull/3276](https://github.com/jitsi/jitsi-meet/pull/3276)

Note that the source language can be set in a similar way
`APP.conference._room.setLocalParticipantProperty('transcription_language','hi-IN');`

#### [Lib-Jitsi-Meet](https://github.com/jitsi/lib-jitsi-meet)
Small changes were required in the lower level JS library used by Jitsi Meet to parse and send json-messages in a 
separate container and to set and remove local participant properties which is used by Jitsi Meet to add/remove the
language preference

* [https://github.com/jitsi/lib-jitsi-meet/pull/770](https://github.com/jitsi/lib-jitsi-meet/pull/770)
* [https://github.com/jitsi/lib-jitsi-meet/pull/783](https://github.com/jitsi/lib-jitsi-meet/pull/783)

### Future Work
There is always a room of improvement in any project. Some of them can be :

* After Nik's [PR](https://github.com/jitsi/jitsi-meet/pull/3213) added UI elements to enable
transcription, the next step would be to add UI elements for choosing source language for
transcription and target language for translations. 
* Looking into open source alternatives for translations.
* Currently the translations are only displayed as subtitles and are not send as chatbox messages
as it will flood the chatbox with speech-to-text results in translated languages. Another persistant
UI element to display the translated results in desired languages can be helpful for people joining
the conference at a later stage to go through the past events in the desired language.
* Sending the final transcript in target languages to the fron-end client after a meet gets over.
* Making the option to store final transcripts in all target languages configurable.
* As the work hasn't been tested heavily, it is prone to having minor bugs which needs to be fixed.