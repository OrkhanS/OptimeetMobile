class Api {
  static const String address = "https://optimeet-django-hoojeqdurq-de.a.run.app/";
  static const socketConnectAlert = "ws://optimeet-django-hoojeqdurq-de.a.run.app/ws/alert/?token=";
  static const userslistAndSignUp = address + "api/users/";
  static const login = address + "api/auth/";
  static const myInfo = address + "api/users/me/";
  static const logout = address + "api/logout/";
  static const match = address + "api/match/";
  static const postListAndPost = address + "api/posts/";
  static const myposts = address + "api/my/posts/";
  static const messagesOfRoomID = address + "api/chat/messages/?room_id=";
  static const readLastMessage = address + "api/chat/readlast/";
  static const listOfChats = address + "api/chats/";

}
