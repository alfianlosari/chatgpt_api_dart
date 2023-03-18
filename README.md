# ChatGPT Client

Access OpenAI ChatGPT Official API using Dart Language. Supports any Dart project and all Flutter target platforms (iOS, Android, Windows, Linux, Web)

## Features

- Using OpenAI ChatGPT Official Completions API Endpoint.
- Maintain Chat History List on the client (~4000 tokens) so new prompt is aware of the previous chat context.
- Support any custom model as Parameter (GPT-3.5, GPT-4, etc)
- Support Stream HTTP Response using native Dart Stream.
- Support Standard HTTP Response.
- Pass custom system prompt and temperature.

## Getting started

Register for API key from [OpenAI](https://openai.com/api). 

## Usage

### Initialization

Initialize with api key. Default model is `gpt-3.5-turbo`.

```dart
import 'package:chatgpt_client/chatgpt_client.dart';

const api = ChatGPTAPI(apiKey: "API_KEY");
```

optionally, you can provide the system prompt, temperature, and model like so.

```dart
const api = ChatGPTAPI(apiKey: "API_KEY",
    model: "gpt-4",
    systemPrompt: "You are a CS Professor",
    temperature: 0.7);
```

There are 2 APIs: stream and normal

### Stream Response

The server will yield chunks of data until the stream completes or throws an error.

```dart
try {
    var text = "";
    final stream = api.sendMessageStream(prompt);
    await for (final textChunk in stream) {
        text += textChunk;
        print(textChunk);
    }
    print(text);
} catch (exception) {
    print(exception.toString());
}
```

### Normal
A normal HTTP request and response lifecycle. Server will send the complete text (it will take more time to response)

```dart
try {
    final text = await api.sendMessage(prompt);
    print(text);
} catch (exception) {
    print(exception.toString());
}   
```

## History List

The client stores the history list of the conversation that will be included in the new prompt so ChatGPT aware of the previous context of conversation. When sending new prompt, the client will make sure the token is not exceeding 4000 (using calculation of 1 token=4chars), in case it exceeded the token, some of previous conversations will be truncated

You can also delete the history list by invoking

```dart
api.clearHistoryList();
```