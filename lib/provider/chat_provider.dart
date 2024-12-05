import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:doxabot/api/api_service.dart';
import 'package:doxabot/constant.dart';
import 'package:doxabot/hive/boxes.dart';
import 'package:doxabot/hive/chat_history.dart';
import 'package:doxabot/hive/setting.dart';
import 'package:doxabot/hive/user_auth.dart';
import 'package:doxabot/hive/user_model.dart';
import 'package:doxabot/model/message.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _inchatMessage = [];

  final PageController _pageController = PageController();

  List<XFile> _imageFileList = [];

  //Index of current screen
  int _currentIndex = 0;

  String _currentChatId = "";

  //Initialize generate model
  GenerativeModel? _model;

  //Initialize text model
  GenerativeModel? _textModel;

  //Initialize image model
  GenerativeModel? _visualModel;

  //current model
  String _modelType = 'gemini-pro';

  //Loading bool
  bool _isloading = false;

  // Getters for the fields

// List of messages
  List<Message> get inchatMessage => _inchatMessage;

// Page controller
  PageController get pageController => _pageController;

  // Images file list
  List<XFile> get imageFileList => _imageFileList;

  // Index of the current screen
  int get currentIndex => _currentIndex;

  // Current chat ID
  String get currentChatId => _currentChatId;

  // Initialize generative model
  GenerativeModel? get model => _model;

  // Initialize text model
  GenerativeModel? get textModel => _textModel;

  // Initialize image model
  GenerativeModel? get visualModel => _visualModel;

  // Current model type
  String get modelType => _modelType;

  // Loading status
  bool get isLoading => _isloading;

  Future<String> registerUser(String username, String email, String password,
      String confirmPassword) async {
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    final box = await Hive.openBox<User>(Constant.userauth);

    // Check for existing user
    if (box.values.any(
        (user) => user.username == username || user.emailaddress == email)) {
      return 'Username or Email already exists';
    }

    // Create and add the new user
    box.add(User(username: username, emailaddress: email, password: password));
    return 'Registration successful';
  }

  Future<String> loginUser(String username, String password) async {
    try {
      var user = await getUserFromDatabase(username);
      if (user == null) {
        return "User not found";
      }
      if (user.password != password) {
        return "Incorrect password";
      }
      return "Login successful";
    } catch (e) {
      print("Error during login: $e");
      return "Login failed: ${e.toString()}";
    }
  }

// Get user from the database
  Future<User?> getUserFromDatabase(String username) async {
    try {
      final box = await Hive.openBox<User>(Constant.userauth);
      // Using a variable to hold the found user
      User? foundUser;

      // Loop through the users to find the matching username
      for (var user in box.values) {
        if (user.username == username) {
          foundUser = user;
          break; // Exit loop if user is found
        }
      }

      return foundUser; // Return the found user or null
    } catch (e) {
      log("Error retrieving user from database: $e");
      return null;
    }
  }

  // set inchatmessages
  Future<void> setInChatMessages({required String chatId}) async {
    //get messages from hive database
    final messeagesFromDB = await loadMessagesFromDB(chatId: chatId);

    for (var message in messeagesFromDB) {
      if (_inchatMessage.contains(message)) {
        log('message already exist');
        continue;
      }
      _inchatMessage.add(message);
    }
    notifyListeners();
  }

  List<ChatHistory> _chatHistory = []; // Store chat history

  // Getter for chat history
  List<ChatHistory> get chatHistory => _chatHistory;

  Future<void> _loadChatHistory() async {
    try {
      var box = await Hive.openBox<ChatHistory>(Constant.chatHistoryBox);
      _chatHistory = box.values.toList();
      notifyListeners();
    } catch (e) {
      print("Error loading chat history: $e");
    }
  }

  // Finish chat and store chat history
  void finishChat() {
    if (_inchatMessage.isNotEmpty) {
      String allMessages = _inchatMessage.map((message) {
        return '${message.role == Role.user ? 'User: ' : 'Assistant: '}${message.message}';
      }).join('\n');

      final chatHistoryEntry = ChatHistory(
        chatid: getChatId(),
        promt: allMessages,
        response: _generateResponse(),
        imageUrl: _extractImageUrls(),
        timestamp: DateTime.now(),
      );

      _chatHistory.add(chatHistoryEntry);
      notifyListeners();
      _saveChatHistoryToDB(chatHistoryEntry); // Save to Hive DB
    }
  }

  List<String> _extractImageUrls() {
    return _inchatMessage
        .where((msg) => msg.imageUrls.isNotEmpty)
        .expand((msg) => msg.imageUrls)
        .toList();
  }

  String _generateResponse() {
    return _inchatMessage
        .where((msg) => msg.role == Role.assistant)
        .map((msg) => msg.message.toString())
        .join('\n');
  }

  Future<void> _saveChatHistoryToDB(ChatHistory chatHistoryEntry) async {
    try {
      var box = await Hive.openBox<ChatHistory>(Constant.chatHistoryBox);
      await box.add(chatHistoryEntry);
    } catch (e) {
      print("Error saving chat history to DB: $e");
    }
  }

  // Start a new chat session
  void startNewChat() {
    _inchatMessage.clear(); // Clear the current messages
    _currentChatId = const Uuid().v4(); // Generate a new chat ID
    _imageFileList.clear(); // Clear the image file list
    _currentIndex = 0; // Reset to the initial index
    notifyListeners(); // Notify listeners of changes
  }

  // Load the messages from DB
  Future<List<Message>> loadMessagesFromDB({required String chatId}) async {
    // Open the box of this ID
    var messageBox = await Hive.openBox('${Constant.chatMessagsBox}$chatId');

    // Get the messages
    final newData = messageBox.keys.map((e) {
      final messages = messageBox.get(e);
      final messageData = Message.fromMap(Map<String, dynamic>.from(messages));
      return messageData;
    }).toList();

    // Notify listeners if necessary
    notifyListeners();

    // Return a list of Message objects
    return newData;
  }

  //Set file list
  void setImageFileList({required List<XFile> listValue}) {
    _imageFileList = listValue;
    notifyListeners();
  }

  //Set current model
  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  //Set current index

  void setCurrentIndex({required int newId}) {
    _currentIndex = newId;
    notifyListeners();
  }

  //Set current chat index

  void setCurrentChatId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool value}) {
    _isloading = value;
    notifyListeners();
  }

  //Function to set the model based on the bool -istextonly

  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: "gemini-pro"),
              apiKey: ApiService.apiKay);
    } else {
      _model = visualModel ??
          GenerativeModel(
              model: setCurrentModel(newModel: "gemini-pro-vision"),
              apiKey: ApiService.apiKay);
    }
    notifyListeners();
  }

  //Send message to gemini and get response

  Future<void> sendMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    try {
      // Set model based on text-only flag
      await setModel(isTextOnly: isTextOnly);

      // Set loading state
      setLoading(value: true);

      // Retrieve chat ID
      String chatId = getChatId();
      if (chatId.isEmpty) {
        throw Exception("Chat ID is empty");
      }

      // Fetch chat history
      List<Content> history = await getHistory(chatId: chatId);
      print("Retrieved ${history.length} messages from history");

      // Get image URLs if applicable
      List<String> imagesUrls = getImagesUrls(isTextOnly: isTextOnly);
      print("Image URLs: $imagesUrls");

      final userMessageId = const Uuid().v4();

      // Create the user message
      final userMessage = Message(
        messageId: userMessageId,
        chatId: chatId,
        role: Role.user,
        message: StringBuffer(message),
        imageUrls: imagesUrls,
        timeSent: DateTime.now(),
      );

      // Add the user message to the chat
      _inchatMessage.add(userMessage);
      notifyListeners();

      // Set current chat ID if not already set
      if (currentChatId.isEmpty) {
        setCurrentChatId(newChatId: chatId);
      }

      // Send the message and wait for the response
      await sendMessageAndWaitForResponse(
        message: message,
        chatId: chatId,
        isTextOnly: isTextOnly,
        history: history,
        userMessage: userMessage,
      );
    } catch (e) {
      print("Error in sendMessage: $e");
      setLoading(value: false);
    }
  }

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
  }) async {
    try {
      // Start a chat session with history (if available)
      final chatSession =
          _model?.startChat(history: history.isEmpty ? null : history);
      if (chatSession == null) {
        throw Exception("Chat session initialization failed");
      }
      print("Chat session started");

      // Fetch content for the message
      final content =
          await getContent(message: message, isTextOnly: isTextOnly);
      print("Fetched content: $content");

      // assistant id

      final modelMessageId = const Uuid().v4();

      // Create the assistant message
      final assistantMessage = userMessage.copyWith(
        messageId: modelMessageId,
        role: Role.assistant,
        message: StringBuffer(),
        timeSent: DateTime.now(),
      );

      // Add the assistant message to the chat
      _inchatMessage.add(assistantMessage);
      notifyListeners();

      // Stream the response from the chat session
      await for (var event in chatSession.sendMessageStream(content)) {
        print("Streamed event: ${event.text}");
        final targetMessage = _inchatMessage.firstWhere(
          (msg) =>
              msg.messageId == assistantMessage.messageId &&
              msg.role.name == Role.assistant.name,
          orElse: () => throw Exception("Assistant message not found"),
        );

        targetMessage.message.write(event.text);
        notifyListeners();
      }

      // Perform cleanup or final steps
      print("Message stream completed");
      setLoading(value: false);
    } catch (e, stackTrace) {
      print("Error in sendMessageAndWaitForResponse: $e\n$stackTrace");
      setLoading(value: false);
    }
  }

  Future<Content> getContent(
      {required message, required bool isTextOnly}) async {
    if (isTextOnly) {
      // generate text from text only input
      return Content.text(message);
    } else {
      // generate text from visual only input
      final imageFutures = _imageFileList
          ?.map((imageFile) => imageFile.readAsBytes())
          .toList(growable: false);

      final imageByte = await Future.wait(imageFutures!);
      final promt = TextPart(message);
      final imagePart = imageByte
          .map((bytes) => DataPart('image/jpg', Uint8List.fromList(bytes)))
          .toList();

      return Content.model([promt, ...imagePart]);
    }
  }

  List<String> getImagesUrls({required bool isTextOnly}) {
    List<String> imagesUrls = [];
    if (!isTextOnly && imageFileList != null) {
      for (var image in imageFileList) {
        imagesUrls.add(image.path);
      }
    }
    return imagesUrls;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    List<Content> history = [];
    if (currentChatId.isNotEmpty) {
      await setInChatMessages(chatId: chatId);
      for (var messsage in inchatMessage) {
        if (messsage.role == Role.user) {
          history.add(Content.text(messsage.message.toString()));
        } else {
          history.add(Content.model([TextPart(messsage.message.toString())]));
        }
      }
    }

    return history;
  }

  String getChatId() {
    if (currentChatId.isEmpty) {
      return const Uuid().v4();
    } else {
      return currentChatId;
    }
  }

  static Future<void> initHive() async {
    // Ensure Flutter is initialized
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserMOdelAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserAdapter());
    }

    // Open boxes after registering adapters
    await Hive.openBox<ChatHistory>(Constant.chatHistoryBox);
    await Hive.openBox<UserMOdel>(Constant.userBox);
    await Hive.openBox<Setting>(Constant.settingsBox);
    await Hive.openBox<User>(Constant.userauth);
  }

  Future<void> _initializeProvider() async {
    await Hive.openBox<ChatHistory>(Constant.chatHistoryBox);
    _loadChatHistory();
  }
}
